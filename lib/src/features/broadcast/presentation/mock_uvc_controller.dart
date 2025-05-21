import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';

/// A simplified mock implementation of a camera controller
class MockUvcCameraController {
  final Logger _logger = Logger('MockUvcCameraController');
  final Map<String, dynamic> _device;
  
  // Stream for camera
  late MediaStream stream;
  
  // Device properties
  final int width;
  final int height;
  final int fps;
  bool isInitialized = false;
  
  // Event controllers
  final _errorEventController = StreamController<String>.broadcast();
  final _statusEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _buttonEventController = StreamController<Map<String, dynamic>>.broadcast();
  
  MockUvcCameraController(
    this._device, {
    this.width = 640,
    this.height = 480,
    this.fps = 30,
  });
  
  Future<void> initialize() async {
    _logger.info('Initializing mock camera controller for ${_device['name']}');
    
    try {
      // Create local media stream for device
      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'width': width,
          'height': height,
          'frameRate': fps,
        }
      });
      
      stream = localStream;
      isInitialized = true;
      
      // Emit initialized status
      _statusEventController.add({
        'device': _device['name'],
        'status': 'initialized'
      });
      
      _logger.info('Mock camera controller initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize mock camera controller: $e');
      _errorEventController.add('Failed to initialize: $e');
      rethrow;
    }
  }
  
  Future<String> takePicture() async {
    _logger.info('Taking picture with mock camera');
    
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    return 'mock_picture_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
  
  Future<String> startVideoRecording() async {
    _logger.info('Starting video recording with mock camera');
    
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    // Emit recording status
    _statusEventController.add({
      'device': _device['name'],
      'status': 'recording'
    });
    
    return 'mock_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }
  
  Future<void> stopVideoRecording() async {
    _logger.info('Stopping video recording with mock camera');
    
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    // Emit stopped status
    _statusEventController.add({
      'device': _device['name'],
      'status': 'stopped'
    });
  }
  
  Future<Uint8List> captureFrame() async {
    _logger.info('Capturing frame with mock camera');
    
    if (!isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    // Return an empty byte array
    return Uint8List(0);
  }
  
  Future<void> dispose() async {
    _logger.info('Disposing mock camera controller');
    
    // Close streams
    if (isInitialized) {
      stream.getTracks().forEach((track) => track.stop());
    }
    
    // Close controllers
    _errorEventController.close();
    _statusEventController.close();
    _buttonEventController.close();
    
    isInitialized = false;
  }
  
  /// Simulate a camera error
  void simulateError(String errorMessage) {
    _logger.warning('Simulating camera error: $errorMessage');
    _errorEventController.add(errorMessage);
  }
  
  /// Simulate a button press
  void simulateButtonPress() {
    _logger.info('Simulating button press on mock camera');
    _buttonEventController.add({
      'device': _device['name'],
      'button': 'capture'
    });
  }
  
  /// Simulate camera status change
  void simulateStatusChange(String status) {
    _logger.info('Simulating status change to: $status');
    _statusEventController.add({
      'device': _device['name'],
      'status': status
    });
  }
  
  // Event streams
  Stream<String> get errorEventStream => _errorEventController.stream;
  Stream<Map<String, dynamic>> get statusEventStream => _statusEventController.stream;
  Stream<Map<String, dynamic>> get buttonEventStream => _buttonEventController.stream;
} 