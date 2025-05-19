import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/core/utils/vibration_handler.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/broadcast/data/camera_controller_service.dart';
import 'package:lavie/src/features/broadcast/data/webrtc_connection_service.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> with WidgetsBindingObserver {
  bool _isStreaming = false;
  RTCVideoRenderer? _localRenderer;
  String? _connectionStatus;
  WebRTCConnectionService? _webRTCService;
  VibrationHandler? _vibrationHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeServices();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _disposeServices();
    } else if (state == AppLifecycleState.resumed) {
      _initializeServices();
    }
  }

  Future<void> _initializeServices() async {
    // Initialize WebRTC renderer
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      // Initialize WebRTC service
      final params = WebRTCConnectionParams(
        userId: currentUser.id,
        pairedUserId: currentUser.pairedDeviceId,
        isBroadcaster: true,
      );
      
      _webRTCService = ref.read(webRTCConnectionServiceProvider(params));
      _webRTCService!.onConnectionStateChange = (state) {
        setState(() {
          _connectionStatus = state.toString().split('.').last;
        });
      };
      
      // Initialize vibration handler
      _vibrationHandler = ref.read(vibrationHandlerProvider(currentUser.id));
      _vibrationHandler!.startListening();
      
      setState(() {});
    }
  }

  void _disposeServices() {
    _localRenderer?.dispose();
    _localRenderer = null;
    _webRTCService = null;
    _vibrationHandler?.dispose();
    _vibrationHandler = null;
  }



  void _toggleCameraDirection() {
    final cameraService = ref.read(cameraControllerServiceProvider);
    cameraService.toggleCamera();
    setState(() {});
  }

  Future<void> _toggleStreaming() async {
    if (_webRTCService == null || _localRenderer == null) return;
    
    final cameraService = ref.read(cameraControllerServiceProvider);
    if (!cameraService.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not initialized')),
      );
      return;
    }
    
    if (!_isStreaming) {
      // Start streaming
      try {
        // Get camera stream
        final cameraController = cameraService.controller;
        if (cameraController == null) throw Exception('Camera controller is null');
        
        // Create a local stream for WebRTC
        final localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'mandatory': {
              'minWidth': '640',
              'minHeight': '480',
              'minFrameRate': '30',
            },
            'facingMode': cameraService.isRearCameraSelected ? 'environment' : 'user',
            'optional': [],
          }
        });
        
        // Assign the stream to the local renderer
        _localRenderer!.srcObject = localStream;
        
        // Start broadcasting
        await _webRTCService!.startBroadcast(localStream);
        
        setState(() {
          _isStreaming = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start streaming: $e')),
        );
      }
    } else {
      // Stop streaming
      try {
        await _webRTCService!.stopBroadcast();
        
        // Stop the local renderer
        if (_localRenderer?.srcObject != null) {
          _localRenderer!.srcObject!.getTracks().forEach((track) {
            track.stop();
          });
          _localRenderer!.srcObject = null;
        }
        
        setState(() {
          _isStreaming = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop streaming: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    if (_isStreaming) {
      await _webRTCService?.stopBroadcast();
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
    final cameraService = ref.watch(cameraControllerServiceProvider);
    final cameraController = cameraService.controller;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast'),
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
              color: _isStreaming ? Colors.green.shade100 : Colors.grey.shade200,
              child: Row(
                children: [
                  Icon(
                    _isStreaming ? Icons.cast_connected : Icons.cast,
                    color: _isStreaming ? Colors.green.shade800 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isStreaming
                          ? 'Broadcasting live'
                          : isPaired
                              ? 'Ready to broadcast'
                              : 'Not paired with a viewer',
                      style: TextStyle(
                        color: _isStreaming
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
            
            // Camera preview
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: ref.watch(cameraInitializationProvider).when(
                  data: (initialized) {
                    if (initialized && cameraController != null) {
                      return Stack(
                        children: [
                          // Camera preview
                          Center(
                            child: AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
                              child: CameraPreview(cameraController),
                            ),
                          ),
                          
                          // Camera controls overlay
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Flip camera button
                                FloatingActionButton(
                                  heroTag: 'flipCamera',
                                  mini: true,
                                  onPressed: _toggleCameraDirection,
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  child: const Icon(
                                    Icons.flip_camera_ios,
                                    color: Colors.black,
                                  ),
                                ),
                                
                                // Stream button
                                FloatingActionButton.large(
                                  heroTag: 'stream',
                                  onPressed: isPaired ? _toggleStreaming : null,
                                  backgroundColor: _isStreaming
                                      ? Colors.red
                                      : isPaired
                                          ? AppTheme.primaryColor
                                          : Colors.grey,
                                  child: Icon(
                                    _isStreaming ? Icons.stop : Icons.play_arrow,
                                    size: 32,
                                  ),
                                ),
                                
                                // Placeholder for symmetry
                                const SizedBox(width: 40, height: 40),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.no_photography,
                              size: 64,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Camera initialization failed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => ref.refresh(cameraInitializationProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${error.toString()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => ref.refresh(cameraInitializationProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Pairing status
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: isPaired ? Colors.blue.shade50 : Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPaired ? Icons.link : Icons.link_off,
                        color: isPaired ? Colors.blue.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPaired ? 'Paired with Viewer' : 'Not Paired',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPaired ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (!isPaired) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'You need to be paired with a viewer device to start broadcasting.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
