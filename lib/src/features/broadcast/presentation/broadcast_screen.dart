import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/broadcast/presentation/webrtc_service.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

@RoutePage()
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isStreaming = false;
  RTCVideoRenderer? _localRenderer;
  WebRTCService? _webRTCService;
  String? _connectionStatus;
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebRTC();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _disposeWebRTC();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
      _disposeWebRTC();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
      _initializeWebRTC();
    }
  }

  Future<void> _initializeWebRTC() async {
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _webRTCService = WebRTCService(
        userId: currentUser.id,
        pairedUserId: currentUser.pairedDeviceId,
        isBroadcaster: true,
      );

      _webRTCService!.onConnectionStateChange = (state) {
        setState(() {
          _connectionStatus = state;
        });
      };

      setState(() {});
    }
  }

  void _disposeWebRTC() {
    _webRTCService?.dispose();
    _localRenderer?.dispose();
    _localRenderer = null;
    _webRTCService = null;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = _isRearCameraSelected
            ? _cameras!.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras!.first)
            : _cameras!.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras!.first);

        _cameraController = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: true,
        );

        await _cameraController!.initialize();
        
        setState(() {
          _isCameraInitialized = true;
          _isCameraPermissionGranted = true;
        });
      }
    } catch (e) {
      setState(() {
        _isCameraPermissionGranted = false;
      });
      print('Error initializing camera: $e');
    }
  }

  void _disposeCamera() {
    if (_cameraController != null) {
      _cameraController!.dispose();
      _cameraController = null;
    }
    _isCameraInitialized = false;
  }

  void _toggleCameraDirection() {
    if (_cameras == null || _cameras!.length < 2) return;
    
    _disposeCamera();
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
    _initializeCamera();
  }

  Future<void> _toggleStreaming() async {
    if (_webRTCService == null || _localRenderer == null) return;
    
    if (!_isStreaming) {
      // Start streaming
      try {
        await _webRTCService!.startBroadcast(_localRenderer!);
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
                child: _isCameraPermissionGranted
                    ? _isCameraInitialized
                        ? Stack(
                            children: [
                              // Camera preview
                              Center(
                                child: AspectRatio(
                                  aspectRatio: _cameraController!.value.aspectRatio,
                                  child: CameraPreview(_cameraController!),
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
                          )
                        : const Center(child: CircularProgressIndicator())
                    : Center(
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
                              'Camera permission denied',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _initializeCamera,
                              child: const Text('Request Permission'),
                            ),
                          ],
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
