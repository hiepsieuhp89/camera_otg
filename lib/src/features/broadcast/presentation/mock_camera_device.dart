import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';

/// A mock device for simulating camera behavior during debugging
class MockCameraDevice {
  static final MockCameraDevice _instance = MockCameraDevice._internal();
  final Logger _logger = Logger('MockCameraDevice');
  
  // Stream controller for device events
  final _deviceEventsController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Mock devices map
  final Map<String, Map<String, dynamic>> _mockDevices = {};
  
  // Current device state
  String? _connectedDeviceName;
  
  factory MockCameraDevice() {
    return _instance;
  }
  
  MockCameraDevice._internal();
  
  /// Initialize with default devices
  void initialize() {
    _logger.info('Initializing mock camera device');
    
    // Add default mock devices if none exist
    if (_mockDevices.isEmpty) {
      _addMockDevice('Mock Camera 1', '00001');
      _addMockDevice('Mock Camera 2', '00002');
    }
  }
  
  /// Add a mock device
  void _addMockDevice(String name, String id) {
    _mockDevices[name] = {
      'id': id,
      'name': name,
      'manufacturer': 'Mock Manufacturer',
      'serialNumber': 'SN-$id',
      'vendorId': 0x0000,
      'productId': 0x0000,
      'isConnected': false,
    };
    
    _logger.info('Added mock device: $name');
  }
  
  /// Get mock devices
  Map<String, Map<String, dynamic>> getMockDevices() {
    return _mockDevices;
  }
  
  /// Simulate device attached
  Future<void> simulateDeviceAttached(Map<String, dynamic> device) async {
    final deviceName = device['name'] as String;
    _logger.info('Simulating device attached: $deviceName');
    
    // Update device state
    if (_mockDevices.containsKey(deviceName)) {
      _mockDevices[deviceName]!['isAttached'] = true;
      
      // Add device event
      _deviceEventsController.add({
        'type': 'attached',
        'device': deviceName
      });
    }
  }
  
  /// Simulate device connected
  Future<void> simulateDeviceConnected(Map<String, dynamic> device) async {
    final deviceName = device['name'] as String;
    _logger.info('Simulating device connected: $deviceName');
    
    // Update device state
    if (_mockDevices.containsKey(deviceName)) {
      _mockDevices[deviceName]!['isConnected'] = true;
      _connectedDeviceName = deviceName;
      
      // Add device event
      _deviceEventsController.add({
        'type': 'connected',
        'device': deviceName
      });
    }
  }
  
  /// Simulate device detached
  Future<void> simulateDeviceDetached(Map<String, dynamic> device) async {
    final deviceName = device['name'] as String;
    _logger.info('Simulating device detached: $deviceName');
    
    // Update device state
    if (_mockDevices.containsKey(deviceName)) {
      _mockDevices[deviceName]!['isAttached'] = false;
      
      // Add device event
      _deviceEventsController.add({
        'type': 'detached',
        'device': deviceName
      });
    }
  }
  
  /// Simulate device disconnected
  Future<void> simulateDeviceDisconnected(Map<String, dynamic> device) async {
    final deviceName = device['name'] as String;
    _logger.info('Simulating device disconnected: $deviceName');
    
    // Update device state
    if (_mockDevices.containsKey(deviceName)) {
      _mockDevices[deviceName]!['isConnected'] = false;
      if (_connectedDeviceName == deviceName) {
        _connectedDeviceName = null;
      }
      
      // Add device event
      _deviceEventsController.add({
        'type': 'disconnected',
        'device': deviceName
      });
    }
  }
  
  /// Simulate camera error
  void simulateCameraError(String errorMessage) {
    _logger.warning('Simulating camera error: $errorMessage');
    
    // Add error event
    _deviceEventsController.add({
      'type': 'error',
      'message': errorMessage,
      'device': _connectedDeviceName
    });
  }
  
  /// Simulate button event
  void simulateButtonEvent(String buttonType) {
    if (_connectedDeviceName == null) {
      _logger.warning('Cannot simulate button event: No device connected');
      return;
    }
    
    _logger.info('Simulating button event: $buttonType');
    
    // Add button event
    _deviceEventsController.add({
      'type': 'button',
      'button': buttonType,
      'device': _connectedDeviceName
    });
  }
  
  /// Create a mock media stream for testing
  Future<MediaStream> createMockMediaStream({
    bool includeVideo = true,
    bool includeAudio = true
  }) async {
    _logger.info('Creating mock media stream (video: $includeVideo, audio: $includeAudio)');
    
    try {
      // Create constraints based on parameters
      final constraints = {
        'audio': includeAudio,
        'video': includeVideo ? {
          'width': 640,
          'height': 480,
        } : false,
      };
      
      // Get user media with these constraints
      final mediaStream = await navigator.mediaDevices.getUserMedia(constraints);
      
      _logger.info('Successfully created mock media stream');
      return mediaStream;
    } catch (e) {
      _logger.severe('Error creating mock media stream: $e');
      throw Exception('Failed to create mock media stream: $e');
    }
  }
  
  /// Get stream of device events
  Stream<Map<String, dynamic>> get deviceEvents => _deviceEventsController.stream;
  
  /// Get current connected device
  Map<String, dynamic>? get connectedDevice {
    return _connectedDeviceName != null ? _mockDevices[_connectedDeviceName] : null;
  }
  
  /// Check if a device is connected
  bool get isDeviceConnected => _connectedDeviceName != null;
  
  /// Dispose resources
  void dispose() {
    _logger.info('Disposing mock camera device');
    _deviceEventsController.close();
  }
} 