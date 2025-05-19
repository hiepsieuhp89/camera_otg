import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to manage camera functionality
class CameraControllerService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRearCameraSelected = true;
  
  /// Initialize the camera
  Future<void> initialize() async {
    // Request camera permission
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      throw Exception('Camera permission denied');
    }
    
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Select camera based on preference
      final camera = _isRearCameraSelected
          ? _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first)
          : _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first);
      
      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      
      await _cameraController!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw Exception('Failed to initialize camera: $e');
    }
  }
  
  /// Toggle between front and rear camera
  Future<void> toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('Cannot toggle camera: not enough cameras available');
    }
    
    // Dispose current controller
    await dispose();
    
    // Toggle camera selection
    _isRearCameraSelected = !_isRearCameraSelected;
    
    // Reinitialize with new camera
    await initialize();
  }
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get camera controller
  CameraController? get controller => _cameraController;
  
  /// Get current camera direction
  bool get isRearCameraSelected => _isRearCameraSelected;
  
  /// Dispose camera controller
  Future<void> dispose() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    _isInitialized = false;
  }
}

/// Provider for the camera controller service
final cameraControllerServiceProvider = Provider<CameraControllerService>((ref) {
  final service = CameraControllerService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for the camera initialization state
final cameraInitializationProvider = FutureProvider<bool>((ref) async {
  final cameraService = ref.watch(cameraControllerServiceProvider);
  try {
    await cameraService.initialize();
    return true;
  } catch (e) {
    return false;
  }
});
