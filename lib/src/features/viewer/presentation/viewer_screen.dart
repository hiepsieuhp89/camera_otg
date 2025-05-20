import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/device/data/device_service.dart';
import 'package:lavie/src/theme/app_theme.dart';

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
  
  @override
  void initState() {
    super.initState();
    _checkForConnectedDevice();
  }
  
  @override
  void dispose() {
    _deviceStreamSubscription?.cancel();
    super.dispose();
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
    });
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
          : _buildStreamView(),
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
  
  Widget _buildStreamView() {
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
                      _isStreamActive ? 'Broadcasting active' : 'Waiting for broadcast',
                      style: TextStyle(
                        color: _isStreamActive ? Colors.green : Colors.grey,
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
        
        // Video stream (placeholder since actual video would require WebRTC)
        Expanded(
          child: Container(
            color: Colors.black,
            child: _isStreamActive
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
                          'Live Stream',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Video stream would appear here',
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