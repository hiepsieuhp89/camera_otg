import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/features/broadcast/data/webrtc_service.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  DeviceModel? _connectedDevice;
  StreamSubscription? _deviceStreamSubscription;
  bool _isConnecting = false;
  String? _errorMessage;
  bool _isStreamActive = false;
  
  // WebRTC
  RTCVideoRenderer? _remoteRenderer;
  bool _isWebRTCConnected = false;
  
  @override
  void initState() {
    super.initState();
    _checkForConnectedDevice();
    _initializeWebRTC();
  }
  
  @override
  void dispose() {
    _deviceStreamSubscription?.cancel();
    
    // Clean up WebRTC
    ref.read(webRTCServiceProvider).dispose();
    _remoteRenderer?.dispose();
    
    super.dispose();
  }
  
  Future<void> _initializeWebRTC() async {
    try {
      // Check microphone and camera permissions for WebRTC
      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }
      
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }
      
      // Initialize renderer
      _remoteRenderer = RTCVideoRenderer();
      await _remoteRenderer!.initialize();
    } catch (e) {
      print('Error initializing WebRTC: $e');
    }
  }
  
  Future<void> _checkForConnectedDevice() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.pairedDeviceId == null) return;
    
    try {
      final device = await ref.read(deviceServiceProvider).getDevice(user.pairedDeviceId!);
      if (device != null) {
        setState(() {
          _connectedDevice = device;
        });
        _listenForDeviceChanges();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get device: ${e.toString()}';
      });
    }
  }
  
  void _listenForDeviceChanges() {
    final user = ref.read(currentUserProvider);
    if (user == null || user.pairedDeviceId == null) return;
    
    _deviceStreamSubscription?.cancel();
    
    _deviceStreamSubscription = ref
        .read(deviceServiceProvider)
        .deviceStream(user.pairedDeviceId!)
        .listen((device) {
      if (device == null) {
        setState(() {
          _connectedDevice = null;
          _isStreamActive = false;
        });
        return;
      }
      
      setState(() {
        _connectedDevice = device;
        _isStreamActive = device.isBroadcasting;
      });
      
      // If broadcasting state changed to active, connect to WebRTC
      if (device.isBroadcasting && !_isWebRTCConnected) {
        _connectToWebRTCStream(device.id);
      } else if (!device.isBroadcasting && _isWebRTCConnected) {
        _disconnectFromWebRTCStream();
      }
    });
  }
  
  Future<void> _connectToWebRTCStream(String deviceId) async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    
    try {
      // Initialize WebRTC
      final webRTCService = ref.read(webRTCServiceProvider);
      await webRTCService.initializeViewer(deviceId);
      
      // Get remote video renderer
      _remoteRenderer = (await webRTCService.remoteRenderer) as RTCVideoRenderer?;
      
      setState(() {
        _isWebRTCConnected = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to stream: ${e.toString()}';
        _isWebRTCConnected = false;
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  Future<void> _disconnectFromWebRTCStream() async {
    try {
      // Clean up WebRTC
      await ref.read(webRTCServiceProvider).dispose();
      
      setState(() {
        _isWebRTCConnected = false;
      });
    } catch (e) {
      print('Error disconnecting from WebRTC: $e');
    }
  }
  
  Future<void> _sendVibrationSignal(int count) async {
    if (_connectedDevice == null || !_isStreamActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send signal: No active broadcast'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(deviceServiceProvider).sendVibrationSignal(_connectedDevice!.id, count);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent ${count == 1 ? 'single' : 'double'} vibration signal'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send signal: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send signal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final webRTCService = ref.watch(webRTCServiceProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkForConnectedDevice,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.router.pushNamed('/device-pairing'),
          ),
        ],
      ),
      body: user.pairedDeviceId == null
          ? _buildNoPairedDeviceView()
          : _buildStreamView(webRTCService),
    );
  }
  
  Widget _buildNoPairedDeviceView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'No device paired',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'You need to pair with a broadcaster device first.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.router.pushNamed('/device-pairing'),
            icon: const Icon(Icons.link),
            label: const Text('Pair with Device'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreamView(WebRTCService webRTCService) {
    if (_connectedDevice == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(16),
          color: _isStreamActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _isStreamActive ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectedDevice!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isStreamActive 
                          ? _isWebRTCConnected 
                              ? 'Connected to broadcast'
                              : 'Connecting to broadcast...'
                          : 'Waiting for broadcast',
                      style: TextStyle(
                        color: _isStreamActive
                            ? _isWebRTCConnected ? Colors.green : Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isStreamActive)
                OutlinedButton(
                  onPressed: _checkForConnectedDevice,
                  child: const Text('Refresh'),
                ),
            ],
          ),
        ),
        
        // Error message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            width: double.infinity,
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        
        // Video stream
        Expanded(
          child: Container(
            color: Colors.black,
            child: _isStreamActive && _isWebRTCConnected && _remoteRenderer != null && webRTCService.isConnected
                ? RTCVideoView(
                    _remoteRenderer!,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : _isStreamActive && _isConnecting
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Connecting to broadcast...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _isStreamActive
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Broadcast Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Trying to connect to the stream...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Waiting for Broadcast',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'The broadcaster is currently offline',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ),
        
        // Vibration controls
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Send Signal to Broadcaster',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isStreamActive && !_isConnecting
                          ? () => _sendVibrationSignal(1)
                          : null,
                      icon: const Icon(Icons.vibration),
                      label: const Text('Single Vibration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isStreamActive && !_isConnecting
                          ? () => _sendVibrationSignal(2)
                          : null,
                      icon: const Icon(Icons.vibration),
                      label: const Text('Double Vibration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isStreamActive
                    ? 'Send a vibration signal to alert the broadcaster'
                    : 'Wait for broadcast to start before sending signals',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 