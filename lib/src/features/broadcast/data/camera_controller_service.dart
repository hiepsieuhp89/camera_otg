import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:lavie/src/core/utils/logger_service.dart';

/// Service to manage camera functionality
class CameraControllerService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isRearCameraSelected = true;
  bool _isUsingDeviceCamera = true;
  
  // UVC Camera info
  bool _externalCameraDetected = false;
  String? _externalCameraInfo;
  String? _selectedExternalCameraId;
  late LoggerService _logger;
  
  // Flag to track if USB camera permission dialog has been shown
  bool _usbCameraDetected = false;
  
  CameraControllerService({LoggerService? logger}) {
    _logger = logger ?? LoggerService();
    _logger.info("CameraControllerService created");
  }
  
  /// Initialize the camera
  Future<void> initialize() async {
    await _logger.info("Initialize camera called");
    
    // Request camera permission
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      await _logger.error("Camera permission denied");
      throw Exception('Camera permission denied');
    }
    
    try {
      // Get available cameras
      await _logger.info("Getting available device cameras");
      _cameras = await availableCameras();
      await _logger.info("Found ${_cameras?.length} device cameras");
      
      // Log all cameras
      for (int i = 0; i < (_cameras?.length ?? 0); i++) {
        final camera = _cameras![i];
        await _logger.info(" - Camera $i, Facing ${camera.lensDirection == CameraLensDirection.back ? 'back' : 'front'}, Orientation ${camera.sensorOrientation}");
      }
      
      if (_cameras == null || _cameras!.isEmpty) {
        await _logger.error("No device cameras available");
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
      
      await _logger.info("Selected device camera: ${camera.name}");
      
      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
      );
      
      await _logger.info("Initializing device camera controller");
      await _cameraController!.initialize();
      await _logger.info("Device camera controller initialized");
      
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      await _logger.error("Failed to initialize camera: $e");
      throw Exception('Failed to initialize camera: $e');
    }
  }
  
  /// Check if external camera is connected
  Future<bool> isCameraOTGConnected() async {
    await _logger.info("Checking for OTG camera connection");
    try {
      // Check for cameras using WebRTC API
      await _logger.info("Enumerating all media devices");
      final devices = await navigator.mediaDevices.enumerateDevices();
      final videoDevices = devices.where((device) => device.kind == 'videoinput').toList();
      
      await _logger.info("Found ${videoDevices.length} video input devices");
      
      // Log all video devices
      for (var i = 0; i < videoDevices.length; i++) {
        final device = videoDevices[i];
        await _logger.debug("Video device $i: ${device.label} (ID: ${device.deviceId})");
      }
      
      // First check: Did a USB camera permission dialog appear?
      if (_usbCameraDetected) {
        await _logger.info("USB camera permission dialog detected - external camera is connected");
        // If user saw USB permission dialog, we know an external camera is connected
        // But we need to refresh the device list to see the new camera
        
        // Let's enumerate devices one more time after permission granted
        final updatedDevices = await navigator.mediaDevices.enumerateDevices();
        final updatedVideoDevices = updatedDevices.where((device) => device.kind == 'videoinput').toList();
        
        await _logger.info("After USB permission, found ${updatedVideoDevices.length} video devices");
        
        // Log all updated video devices
        for (var i = 0; i < updatedVideoDevices.length; i++) {
          final device = updatedVideoDevices[i];
          await _logger.debug("Updated video device $i: ${device.label} (ID: ${device.deviceId})");
        }
        
        // The most recently added camera is typically the external one
        // Use the LAST camera in the list as the external camera
        if (updatedVideoDevices.isNotEmpty) {
          final lastDevice = updatedVideoDevices.last;
          await _logger.info("Selected external camera (last device): ${lastDevice.label}");
          _externalCameraDetected = true;
          _externalCameraInfo = 'External camera: ${lastDevice.label}';
          _selectedExternalCameraId = lastDevice.deviceId;
          _isUsingDeviceCamera = false;
          return true;
        }
      }
      
      // Second check: Search for external camera based on name patterns
      for (var i = 0; i < videoDevices.length; i++) {
        final device = videoDevices[i];
        final label = device.label.toLowerCase();
        
        // Patterns that suggest an external camera
        final bool isExternal = 
            label.contains('usb') || 
            label.contains('uvc') || 
            label.contains('webcam') || 
            label.contains('pc camera') ||
            (label.contains('camera') && !label.contains('front') && !label.contains('back')) || 
            label.contains('external');
            
        if (isExternal) {
          await _logger.info("Found external camera: ${device.label} (ID: ${device.deviceId})");
          _externalCameraDetected = true;
          _externalCameraInfo = 'External camera: ${device.label}';
          _selectedExternalCameraId = device.deviceId;
          _isUsingDeviceCamera = false;
          return true;
        }
      }
      
      // If we have multiple cameras and couldn't identify an external one by name,
      // try using heuristics - assume the last one might be external if it's different
      if (videoDevices.length > 1) {
        // Compare first and last to see if they're different
        final firstCamera = videoDevices.first;
        final lastCamera = videoDevices.last;
        
        if (firstCamera.label != lastCamera.label) {
          await _logger.info("Using heuristic to identify external camera: ${lastCamera.label}");
          _externalCameraDetected = true;
          _externalCameraInfo = 'Possible external camera: ${lastCamera.label}';
          _selectedExternalCameraId = lastCamera.deviceId;
          _isUsingDeviceCamera = false;
        return true;
        }
      }
      
      await _logger.info("No external camera detected, using device camera");
      _externalCameraDetected = false;
      _externalCameraInfo = null;
      _selectedExternalCameraId = null;
      _isUsingDeviceCamera = true;
      return false;
    } catch (e) {
      await _logger.error("Error checking for external camera: $e");
      _externalCameraDetected = false;
      _externalCameraInfo = null;
      _selectedExternalCameraId = null;
      _isUsingDeviceCamera = true;
      return false;
    }
  }
  
  /// Set flag when USB camera is detected through permission dialog
  void setUsbCameraDetected() {
    _usbCameraDetected = true;
    _logger.info("USB camera detected through permission dialog");
  }
  
  /// Initialize camera and return a MediaStream for WebRTC
  Future<MediaStream?> initializeCamera() async {
    await _logger.info("Initialize camera stream");
    try {
      // Request camera permission
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission != PermissionStatus.granted) {
        await _logger.error("Camera permission denied");
        return null;
      }
      
      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        await _logger.warning("Microphone permission denied");
      }
      
      // Check if external camera is connected FIRST - this is important
      await _logger.info("Checking for external cameras");
      final hasExternalCamera = await isCameraOTGConnected();
      
      // Create media stream using WebRTC
      await _logger.info("Getting video devices for stream");
      final devices = await navigator.mediaDevices.enumerateDevices();
      final videoDevices = devices.where((device) => device.kind == 'videoinput').toList();
      
      // Log all available devices for debugging
      await _logger.info("Available video devices: ${videoDevices.length}");
      for (final device in videoDevices) {
        await _logger.info(" - ${device.label} (${device.deviceId})");
      }
      
      String? deviceId;
      
      // If external camera found, we want to FORCE the use of ONLY that camera
      if (hasExternalCamera && _selectedExternalCameraId != null) {
        deviceId = _selectedExternalCameraId;
        await _logger.info("Prioritizing external camera with ID: $deviceId");
        
        // Create explicit constraints to force specific camera
        try {
          await _logger.info("Attempting to create stream with external camera");
          
          // IMPORTANT: Use the deviceId as a direct string, not wrapped in an 'exact' constraint
          final mediaConstraints = {
            'audio': micPermission == PermissionStatus.granted,
            'video': {
              'deviceId': deviceId,  // Direct string value, not a map with 'exact'
              'width': {'ideal': 1280, 'min': 640},
              'height': {'ideal': 720, 'min': 480},
              'frameRate': {'ideal': 30, 'min': 15}
            }
          };
          
          await _logger.info("External camera constraints: $mediaConstraints");
          final mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          
          // Verify we got the right camera
          final videoTracks = mediaStream.getVideoTracks();
          if (videoTracks.isNotEmpty) {
            final selectedCamera = videoTracks.first;
            await _logger.info("Successfully created stream with camera: ${selectedCamera.label}");
            
            // Verify we got the external camera
            final cameraLabel = selectedCamera.label ?? '';
            if (cameraLabel.contains('usb') || 
                cameraLabel.contains('uvc') || 
                cameraLabel.contains('webcam') ||
                cameraLabel.contains('pc camera') ||
                (_externalCameraInfo != null && cameraLabel.contains(_externalCameraInfo!))) {
              await _logger.info("✅ CONFIRMED using external camera");
              _isUsingDeviceCamera = false;
            } else {
              await _logger.warning("⚠️ External camera requested but got: ${selectedCamera.label}");
              _isUsingDeviceCamera = true;
            }
          }
          
          _isInitialized = true;
          return mediaStream;
        } catch (e) {
          await _logger.error("Failed to create stream with external camera: $e");
          // Continue to fallback
        }
      }
      
      // Fallback: use built-in camera
      await _logger.info("Using built-in camera");
      _isUsingDeviceCamera = true;
      
      // Create fallback stream with built-in camera
      try {
        if (videoDevices.isNotEmpty) {
          // Choose appropriate camera
          if (_isRearCameraSelected && videoDevices.length > 1) {
            deviceId = videoDevices.first.deviceId;
            await _logger.info("Using rear camera (ID: $deviceId)");
          } else {
            deviceId = videoDevices.length > 1 ? videoDevices.last.deviceId : videoDevices.first.deviceId;
            await _logger.info("Using front/default camera (ID: $deviceId)");
          }
        }
        
        final mediaConstraints = deviceId != null ? {
          'audio': micPermission == PermissionStatus.granted,
          'video': {
            'deviceId': deviceId,  // Direct string value, not a map with 'exact'
            'width': {'ideal': 1280, 'min': 640},
            'height': {'ideal': 720, 'min': 480},
            'frameRate': {'ideal': 30, 'min': 15}
          }
        } : {
          'audio': micPermission == PermissionStatus.granted,
          'video': {
            'width': {'ideal': 1280, 'min': 640},
            'height': {'ideal': 720, 'min': 480},
            'frameRate': {'ideal': 30, 'min': 15},
            'facingMode': _isRearCameraSelected ? 'environment' : 'user',
          }
        };
        
        await _logger.info("Built-in camera constraints: $mediaConstraints");
        final mediaStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
        
        final videoTracks = mediaStream.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          await _logger.info("Built-in camera stream created with: ${videoTracks.first.label}");
      }
      
      _isInitialized = true;
      return mediaStream;
    } catch (e) {
        await _logger.error("Error creating built-in camera stream: $e");
        return null;
      }
    } catch (e) {
      await _logger.error("Error in initializeCamera: $e");
      return null;
    }
  }
  
  /// Get external camera info if available
  String? get uvcCameraInfo => _externalCameraInfo;
  
  /// Toggle between front and rear camera
  Future<void> toggleCamera() async {
    await _logger.info("Toggle camera called");
    
    if (_cameras == null || _cameras!.length < 2) {
      await _logger.warning("Cannot toggle camera: not enough cameras available");
      throw Exception('Cannot toggle camera: not enough cameras available');
    }
    
    // Dispose current controller
    await dispose();
    
    // Toggle camera selection
    _isRearCameraSelected = !_isRearCameraSelected;
    await _logger.info("Camera toggled to: ${_isRearCameraSelected ? 'rear' : 'front'}");
    
    // Reinitialize with new camera
    await initialize();
  }
  
  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get camera controller
  CameraController? get controller => _cameraController;
  
  /// Get current camera direction
  bool get isRearCameraSelected => _isRearCameraSelected;
  
  /// Check if using device camera (not OTG)
  bool get isUsingDeviceCamera => _isUsingDeviceCamera;
  
  /// Dispose camera controller
  Future<void> dispose() async {
    await _logger.info("Disposing camera controller");
    
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      await _logger.info("Camera controller disposed");
    }
    
    _isInitialized = false;
  }
  
  /// Get log file path
  Future<String> getLogFilePath() async {
    return await _logger.getLogFilePath();
  }
}

/// Provider for the camera controller service
final cameraControllerServiceProvider = Provider<CameraControllerService>((ref) {
  final logger = ref.watch(loggerProvider);
  final service = CameraControllerService(logger: logger);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for the logger
final loggerProvider = Provider<LoggerService>((ref) {
  final logger = LoggerService();
  return logger;
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
