import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logging/logging.dart';
import 'package:lavie/src/features/broadcast/presentation/mock_camera_device.dart';

/// Provider for mock camera service
final mockCameraServiceProvider = Provider<MockCameraService>((ref) {
  return MockCameraService();
});

/// Service that mocks camera methods for debugging without needing a physical device
class MockCameraService {
  final Logger _logger = Logger('MockCameraService');
  final MockCameraDevice _mockDevice = MockCameraDevice();
  bool _isOverriding = false;
  
  /// Stream controller to emulate device event stream
  final _deviceEventStreamController = StreamController<Map<String, dynamic>>.broadcast();
  
  MockCameraService() {
    // Initialize mock device
    _mockDevice.initialize();
    
    // Set up event forwarding
    _mockDevice.deviceEvents.listen((event) {
      _deviceEventStreamController.add(event);
    });
  }
  
  /// Enable/disable override mode
  void setOverrideMode(bool isEnabled) {
    _logger.info('Setting override mode: $isEnabled');
    _isOverriding = isEnabled;
  }
  
  /// Check if using mock devices
  bool get isOverriding => _isOverriding;
  
  /// Get list of mock devices
  Map<String, Map<String, dynamic>> getMockDevices() {
    return _mockDevice.getMockDevices();
  }
  
  /// Mock getDevices()
  Future<Map<String, Map<String, dynamic>>> getDevices() async {
    if (!_isOverriding) {
      try {
        // In a real implementation, this would try to use real devices
        // For our mock implementation, we'll just simulate a failure
        // if the override mode is disabled
        return {};
      } catch (e) {
        _logger.warning('Error getting real devices, switching to mock mode: $e');
        _isOverriding = true;
      }
    }
    
    // If in override mode or no real devices found, return mock devices
    return _mockDevice.getMockDevices();
  }
  
  /// Mock isSupported()
  Future<bool> isSupported() async {
    if (_isOverriding) {
      return true;
    }
    
    try {
      // In a real implementation, this would check hardware support
      // For our mock implementation, we'll return true in override mode
      // or false otherwise
      return false;
    } catch (e) {
      return true; // Always return true when in error to allow testing
    }
  }
  
  /// Mock requestDevicePermission()
  Future<bool> requestDevicePermission(Map<String, dynamic> device) async {
    if (!_isOverriding) {
      try {
        // In a real implementation, this would request actual permissions
        // For our mock implementation, we'll just simulate a failure
        // if the override mode is disabled
        return false;
      } catch (e) {
        _logger.warning('Error requesting real device permission, switching to mock mode: $e');
        _isOverriding = true;
      }
    }
    
    // Simulate device connection sequence
    await _mockDevice.simulateDeviceAttached(device);
    await Future.delayed(const Duration(milliseconds: 500));
    await _mockDevice.simulateDeviceConnected(device);
    return true;
  }
  
  /// Get stream of device events
  Stream<Map<String, dynamic>> get deviceEventStream {
    if (!_isOverriding) {
      try {
        // In a real implementation, this would return the real device event stream
        // For our mock implementation, we'll use the mock device events
        _isOverriding = true;
      } catch (e) {
        _logger.warning('Error getting real device event stream, switching to mock mode: $e');
        _isOverriding = true;
      }
    }
    
    return _deviceEventStreamController.stream;
  }
  
  /// Utility methods to simulate camera events
  
  Future<void> simulateDeviceAttached(Map<String, dynamic> device) async {
    await _mockDevice.simulateDeviceAttached(device);
  }
  
  Future<void> simulateDeviceConnected(Map<String, dynamic> device) async {
    await _mockDevice.simulateDeviceConnected(device);
  }
  
  Future<void> simulateDeviceDetached(Map<String, dynamic> device) async {
    await _mockDevice.simulateDeviceDetached(device);
  }
  
  Future<void> simulateDeviceDisconnected(Map<String, dynamic> device) async {
    await _mockDevice.simulateDeviceDisconnected(device);
  }
  
  void simulateCameraError(String errorMessage) {
    _mockDevice.simulateCameraError(errorMessage);
  }
  
  /// Create a mock media stream
  Future<MediaStream> createMockMediaStream({bool includeVideo = true, bool includeAudio = true}) {
    return _mockDevice.createMockMediaStream(
      includeVideo: includeVideo,
      includeAudio: includeAudio
    );
  }
  
  /// Check if device is connected
  bool get isDeviceConnected => _mockDevice.isDeviceConnected;
  
  /// Get current connected device
  Map<String, dynamic>? get connectedDevice => _mockDevice.connectedDevice;
  
  /// Dispose resources
  void dispose() {
    _deviceEventStreamController.close();
  }
} 