import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/core/utils/vibration_handler.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/broadcast/data/webrtc_connection_service.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:vibration/vibration.dart';

@RoutePage()
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  RTCVideoRenderer? _remoteRenderer;
  WebRTCConnectionService? _webRTCService;
  VibrationHandler? _vibrationHandler;
  bool _isConnected = false;
  String? _connectionStatus;
  bool _isVibrationSupported = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _disposeServices();
    super.dispose();
  }

  Future<void> _checkVibrationSupport() async {
    final isSupported = await Vibration.hasVibrator();
    setState(() {
      _isVibrationSupported = isSupported == true;
    });
  }

  Future<void> _initializeServices() async {
    // Initialize remote renderer
    _remoteRenderer = RTCVideoRenderer();
    await _remoteRenderer!.initialize();
    
    // Check vibration support
    await _checkVibrationSupport();
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && currentUser.pairedDeviceId != null) {
      // Initialize WebRTC service
      final params = WebRTCConnectionParams(
        userId: currentUser.id,
        pairedUserId: currentUser.pairedDeviceId,
        isBroadcaster: false,
      );
      
      _webRTCService = ref.read(webRTCConnectionServiceProvider(params));
      
      _webRTCService!.onConnectionStateChange = (state) {
        setState(() {
          _connectionStatus = state.toString().split('.').last;
          _isConnected = state == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
        });
      };
      
      _webRTCService!.onRemoteStreamAvailable = (stream) {
        if (_remoteRenderer != null) {
          _remoteRenderer!.srcObject = stream;
          setState(() {});
        }
      };
      
      // Initialize vibration handler
      _vibrationHandler = ref.read(vibrationHandlerProvider(currentUser.id));
      
      setState(() {});
    }
  }

  void _disposeServices() {
    _webRTCService?.dispose();
    _remoteRenderer?.dispose();
    _remoteRenderer = null;
    _webRTCService = null;
    _vibrationHandler?.dispose();
    _vibrationHandler = null;
  }

  Future<void> _startViewing() async {
    if (_webRTCService == null || _remoteRenderer == null) return;
    
    try {
      await _webRTCService!.startViewing();
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  Future<void> _stopViewing() async {
    if (_webRTCService == null) return;
    
    try {
      await _webRTCService!.stopViewing();
      setState(() {
        _isConnected = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disconnect: $e')),
      );
    }
  }

  Future<void> _sendVibration(int pattern) async {
    if (!_isVibrationSupported) return;
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.pairedDeviceId == null || _vibrationHandler == null) return;
    
    try {
      // Send vibration to paired device
      await _vibrationHandler!.sendVibration(currentUser.pairedDeviceId!, pattern);
      
      // Also vibrate the current device for feedback
      if (pattern == 1) {
        Vibration.vibrate(duration: 300);
      } else if (pattern == 2) {
        Vibration.vibrate(pattern: [0, 300, 100, 300]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send vibration: $e')),
      );
    }
  }

  Future<void> _logout() async {
    if (_isConnected) {
      await _webRTCService?.stopViewing();
    }
    await ref.read(currentUserProvider.notifier).logout();
    if (mounted) {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isPaired = currentUser?.pairedDeviceId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _isConnected ? Colors.green.shade100 : Colors.grey.shade200,
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.connected_tv : Icons.tv_off,
                    color: _isConnected ? Colors.green.shade800 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isConnected
                          ? 'Connected to broadcast'
                          : isPaired
                              ? 'Ready to connect'
                              : 'Not paired with a broadcaster',
                      style: TextStyle(
                        color: _isConnected
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_connectionStatus != null)
                    Text(
                      _connectionStatus!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Video stream
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: _isConnected && _remoteRenderer != null
                    ? RTCVideoView(
                        _remoteRenderer!,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPaired ? Icons.videocam_off : Icons.link_off,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isPaired
                                  ? 'Not connected to broadcast'
                                  : 'Not paired with a broadcaster',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (isPaired && !_isConnected)
                              ElevatedButton(
                                onPressed: _startViewing,
                                child: const Text('Connect to Broadcast'),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Vibration controls
            Container(
              padding: const EdgeInsets.all(16),
              color: _isVibrationSupported ? Colors.white : Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vibration Controls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isVibrationSupported && _isConnected
                              ? () => _sendVibration(1)
                              : null,
                          icon: const Icon(Icons.vibration),
                          label: const Text('Vibrate Once'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isVibrationSupported && _isConnected
                              ? () => _sendVibration(2)
                              : null,
                          icon: const Icon(Icons.vibration),
                          label: const Text('Vibrate Twice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isVibrationSupported) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Vibration is not supported on this device.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Connection controls
            if (_isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade50,
                child: ElevatedButton.icon(
                  onPressed: _stopViewing,
                  icon: const Icon(Icons.close),
                  label: const Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
