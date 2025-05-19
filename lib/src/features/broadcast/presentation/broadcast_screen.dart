import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// Receiver for USB device connected broadcasts
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/core/utils/logger_service.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/broadcast/data/camera_controller_service.dart';
import 'package:lavie/src/features/broadcast/data/webrtc_connection_service.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class BroadcastScreen extends ConsumerStatefulWidget {
  const BroadcastScreen({super.key});

  @override
  ConsumerState<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends ConsumerState<BroadcastScreen> with WidgetsBindingObserver {
  final _localRenderer = RTCVideoRenderer();
  CameraControllerService? _cameraService;
  WebRTCConnectionService? _webRTCService;
  bool _isCameraInitialized = false;
  bool _isStreaming = false;
  bool _isRendererInitialized = false;
  String? _logFilePath;
  late LoggerService _logger;
  
  // Platform channel for listening to system dialogs
  static const platform = MethodChannel('com.lavie.app/usb_camera');
  
  // Timer to periodically check for USB devices
  Timer? _usbCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initLogger();
      _setupUsbChannelListener();
      _startUsbCheckTimer();
      _initializeServices();
    });
  }
  
  // Setup USB camera detection
  void _setupUsbChannelListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'usbCameraPermissionRequested') {
        await _logger.info("USB Camera permission dialog detected from native");
        if (_cameraService != null && mounted && _isRendererInitialized) {
          _cameraService!.setUsbCameraDetected();
          // Reinitialize to use the USB camera
          await _reinitializeCamera();
        } else {
          await _logger.warning("USB camera detected but renderer not ready: renderer initialized: $_isRendererInitialized, mounted: $mounted");
        }
      }
      return null;
    });
  }
  
  // Start a timer to check for camera intent dialogs
  void _startUsbCheckTimer() {
    _usbCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Only check when mounted and renderer is initialized
      if (_cameraService != null && mounted && _isRendererInitialized) {
        try {
          // Use the channel to check for USB devices
          final hasUsbDevices = await platform.invokeMethod<bool>('checkForUSBCameras');
          await _logger.info("Checking for USB cameras, result: $hasUsbDevices");
          
          if (hasUsbDevices == true) {
            await _logger.info("USB camera detected through timer check");
            _cameraService!.setUsbCameraDetected();
            
            // Only reinitialize if we're not currently streaming and renderer is ready
            if (!_isStreaming && _isRendererInitialized) {
              await _reinitializeCamera();
            } else {
              await _logger.info("Not reinitializing camera: streaming=$_isStreaming, renderer initialized=$_isRendererInitialized");
            }
          } else {
            // Also check for dialogs as a fallback
            _checkForUsbCameraDialog();
          }
        } catch (e) {
          // If platform channel fails, fall back to dialog check
          await _logger.warning("Error checking for USB cameras: $e");
          if (mounted && _isRendererInitialized) {
            _checkForUsbCameraDialog();
          }
        }
      } else {
        await _logger.info("Skipping USB camera check - not ready: renderer initialized: $_isRendererInitialized, mounted: $mounted");
      }
    });
  }
  
  void _checkForUsbCameraDialog() {
    // This is a fallback mechanism now that we have direct USB detection
    if (_cameraService != null && !_isStreaming) {
      try {
        // Check if there are any system dialogs open that might be USB permission dialogs
        // This is just an additional heuristic
        _cameraService!.setUsbCameraDetected();
      } catch (e) {
        // Handle any errors
        _logger.warning("Error in USB dialog check: $e");
      }
    }
  }

  Future<void> _initLogger() async {
    _logger = LoggerService();
    await _logger.initialize();
    await _logger.info("BroadcastScreen initialized");
    final path = await _logger.getLogFilePath();
    setState(() {
      _logFilePath = path;
    });
  }
  
  Future<void> _reinitializeCamera() async {
    if (!mounted) {
      await _logger.warning("Not reinitializing camera - widget not mounted");
      return;
    }
    
    if (!_isRendererInitialized) {
      await _logger.warning("Not reinitializing camera - renderer not initialized");
      return;
    }
    
    await _logger.info("Reinitializing camera after USB device detected");
    
    try {
      // Dispose current stream
      if (_localRenderer.srcObject != null) {
        final tracks = _localRenderer.srcObject!.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        _localRenderer.srcObject = null;
      }
      
      // Wait a moment for the camera to be ready after USB permission
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Check again if still mounted and renderer is initialized
      if (!mounted || !_isRendererInitialized) {
        await _logger.warning("Widget state changed during reinitialization, aborting");
        return;
      }
      
      // Get new stream
      final stream = await _cameraService?.initializeCamera();
      if (stream != null) {
        // Double check renderer is still initialized before setting srcObject
        if (_isRendererInitialized && mounted) {
          _localRenderer.srcObject = stream;
          await _logger.info("Camera reinitialized successfully with USB camera");
          
          setState(() {
            _isCameraInitialized = true;
          });
        } else {
          // Clean up the stream if we can't use it
          final tracks = stream.getTracks();
          for (var track in tracks) {
            track.stop();
          }
          await _logger.error("Renderer disposed during camera reinitialization");
        }
      } else {
        await _logger.error("Failed to reinitialize camera after USB detection");
      }
    } catch (e) {
      await _logger.error("Error in camera reinitialization: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _usbCheckTimer?.cancel();
    _disposeServices();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info('App lifecycle state changed: $state');
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _logger.info('App inactive/paused, disposing services...');
      _disposeServices();
    } else if (state == AppLifecycleState.resumed) {
      _logger.info('App resumed, re-initializing services...');
      _initializeServices();
    }
  }

  Future<void> _initializeServices() async {
    await _logger.info('_initializeServices called');
    try {
      if (!_isRendererInitialized && mounted) {
        await _logger.info('Initializing _localRenderer...');
        await _localRenderer.initialize();
        if (mounted) {
          setState(() {
            _isRendererInitialized = true;
          });
        }
        await _logger.info('_localRenderer initialized');
      } else {
        await _logger.info('_localRenderer already initialized or widget not mounted');
      }

      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        await _logger.info('Not logged in.');
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
        return;
      }
      
      _cameraService = ref.read(cameraControllerServiceProvider);
      await _logger.info('Initializing camera...');
      
      // Only proceed if the renderer is initialized and widget is mounted
      if (_isRendererInitialized && mounted) {
        final stream = await _cameraService?.initializeCamera();
        
        if (stream == null) {
          await _logger.error('Failed to initialize camera.');
          _localRenderer.srcObject = null;
          
          if (mounted) {
            setState(() {
              _isCameraInitialized = false;
            });
          }
          return;
        }
        
        // Double check renderer is still initialized
        if (_isRendererInitialized && mounted) {
          _localRenderer.srcObject = stream;
          await _logger.info('Camera stream set to renderer.');
          
          _webRTCService = WebRTCConnectionService(
            userId: currentUser.id,
            isBroadcaster: true,
          );
          
          _webRTCService?.onConnectionStateChange = (state) {
            _logger.info('WebRTC connection state changed: $state');
          };
          
          _webRTCService?.startListeningForVibrations();
          
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        } else {
          // Clean up stream if we can't use it
          final tracks = stream.getTracks();
          for (var track in tracks) {
            track.stop();
          }
          await _logger.error('Renderer disposed before stream could be attached');
        }
      } else {
        await _logger.warning('Cannot initialize camera - renderer not ready or widget not mounted');
      }
    } catch (e) {
      await _logger.error('Error during initialization: $e');
      if (_isRendererInitialized) {
        _localRenderer.srcObject = null;
      }
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _disposeServices() {
    _logger.info('_disposeServices called');
    if (_isStreaming) {
      _webRTCService?.stopBroadcast();
      _isStreaming = false;
    }
    
    // First dispose media streams
    if (_localRenderer.srcObject != null) {
      final tracks = _localRenderer.srcObject!.getTracks();
      for (var track in tracks) {
        track.stop();
      }
      _localRenderer.srcObject = null;
    }
    
    _cameraService?.dispose();
    
    // Then dispose renderer
    if (_isRendererInitialized) {
      _logger.info('Disposing _localRenderer...');
      _localRenderer.dispose();
      _isRendererInitialized = false;
      _logger.info('_localRenderer disposed');
    }
    
    _webRTCService?.dispose();
    _logger.info('Services disposed');
  }

  Future<void> _toggleStreaming() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    
    if (!_isCameraInitialized || _localRenderer.srcObject == null) {
       debugPrint('Cannot toggle streaming: Camera not initialized or stream not available.');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not ready or stream not available')),
      );
      return;
    }
    
    if (_isStreaming) {
      try {
        await _webRTCService?.stopBroadcast();
        setState(() {
          _isStreaming = false;
        });
         debugPrint('Streaming stopped.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping broadcast: $e')),
        );
         debugPrint('Error stopping broadcast: $e');
      }
    } else {
      try {
        final stream = _localRenderer.srcObject;
        if (stream == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera stream not available')),
          );
           debugPrint('Attempted to start streaming but camera stream is null.');
          return;
        }
        
        await _webRTCService?.startBroadcast(stream, currentUser.displayName);
        setState(() {
          _isStreaming = true;
        });
         debugPrint('Streaming started.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start streaming: $e')),
        );
         debugPrint('Failed to start streaming: $e');
      }
    }
  }
  
  Future<void> _shareLogFile() async {
    if (_logFilePath != null) {
      final file = File(_logFilePath!);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(_logFilePath!)], text: 'Camera OTG Log File');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log file not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log file path not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phát trực tiếp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt),
            onPressed: _shareLogFile,
            tooltip: 'Share Log File',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: _buildBroadcastView(),
      floatingActionButton: _isCameraInitialized && _localRenderer.srcObject != null
          ? FloatingActionButton(
              onPressed: _toggleStreaming,
              backgroundColor: _isStreaming ? Colors.red : AppTheme.primaryColor,
              child: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
            )
          : null,
    );
  }
  
  Widget _buildBroadcastView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Icon(
                _isStreaming ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                color: _isStreaming ? Colors.green.shade800 : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isStreaming
                      ? 'Broadcasting live'
                      : _isCameraInitialized && _localRenderer.srcObject != null
                          ? 'Ready to broadcast'
                          : 'Camera not available',
                  style: TextStyle(
                    color: _isStreaming
                        ? Colors.green.shade800
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _isStreaming
                    ? 'LIVE'
                    : 'OFF',
                style: TextStyle(
                  color: _isStreaming ? Colors.red : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_isCameraInitialized && _cameraService != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  _cameraService!.isUsingDeviceCamera 
                      ? Icons.phone_android 
                      : Icons.usb,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _cameraService!.isUsingDeviceCamera
                        ? 'Using device camera (OTG camera not detected)'
                        : _cameraService!.uvcCameraInfo ?? 'Using OTG camera',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: _isCameraInitialized && _localRenderer.srcObject != null
                ? RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Camera not available or failed to initialize.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _initializeServices,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        
        if (_isCameraInitialized && _localRenderer.srcObject != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _isStreaming
                  ? 'Tap the STOP button to end your broadcast'
                  : 'Tap the PLAY button to start broadcasting',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isStreaming ? Colors.red : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Show log file path for debugging
        if (_logFilePath != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Log: ${_logFilePath!}',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
  
  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• Start broadcasting by tapping the play button'),
            const SizedBox(height: 8),
            const Text('• Viewers can connect to your broadcast automatically'),
            const SizedBox(height: 8),
            const Text('• You will feel vibrations when viewers send notifications'),
            const SizedBox(height: 8),
            const Text('• Stop broadcasting by tapping the stop button'),
            const SizedBox(height: 16),
            if (_logFilePath != null)
              Text('Log file: $_logFilePath', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          if (_logFilePath != null)
            TextButton(
              onPressed: _shareLogFile,
              child: const Text('Share Log'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

