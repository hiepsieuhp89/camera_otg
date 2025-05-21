import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uvccamera/uvccamera.dart';

// Local camera device model
class DeviceModel {
  final String id;
  final String name;
  final bool isActive;
  final bool isBroadcasting;
  final String? viewerId;

  DeviceModel({
    required this.id,
    required this.name,
    this.isActive = true,
    this.isBroadcasting = false,
    this.viewerId,
  });

  factory DeviceModel.fromUvcDevice(UvcCameraDevice device) {
    return DeviceModel(
      id: device.name,
      name: device.name,
      isActive: true,
      isBroadcasting: false,
    );
  }

  DeviceModel copyWith({
    String? id,
    String? name, 
    bool? isActive,
    bool? isBroadcasting,
    String? viewerId,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      viewerId: viewerId != null ? viewerId : this.viewerId,
    );
  }
}

// Vibration signal model
class VibrationSignal {
  final String id;
  final int count;
  final DateTime timestamp;
  
  VibrationSignal({
    required this.id,
    required this.count,
    required this.timestamp,
  });
}

class DeviceService {
  // Local state
  Map<String, DeviceModel> _activeDevices = {};
  Map<String, StreamController<DeviceModel?>> _deviceStreamControllers = {};
  Map<String, StreamController<List<VibrationSignal>>> _signalStreamControllers = {};
  final List<VibrationSignal> _recentSignals = [];
  
  // Get all available UVC cameras connected to the device
  Future<List<DeviceModel>> getAvailableDevices() async {
    try {
      // Check if UVC camera is supported
      final isSupported = await UvcCamera.isSupported();
      if (!isSupported) {
        throw Exception('Thiết bị không hỗ trợ camera UVC');
      }
      
      // Get list of cameras
      final devices = await UvcCamera.getDevices();
      if (devices.isEmpty) {
        return [];
      }
      
      // Convert to our device model
      final deviceModels = devices.values.map((device) => 
        DeviceModel.fromUvcDevice(device)
      ).toList();
      
      // Update local cache
      for (var device in deviceModels) {
        _activeDevices[device.id] = device;
      }
      
      return deviceModels;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get active broadcaster devices - this is just a stub now
  Future<List<DeviceModel>> getActiveBroadcasterDevices() async {
    // In the new architecture, we'll use WebRTC service to find active broadcasters
    // This is just a placeholder for compatibility
    return await getAvailableDevices();
  }
  
  // Start broadcasting with a device
  Future<void> startBroadcasting(String deviceId) async {
    if (_activeDevices.containsKey(deviceId)) {
      final updatedDevice = _activeDevices[deviceId]!.copyWith(
        isBroadcasting: true,
      );
      _activeDevices[deviceId] = updatedDevice;
      
      // Notify listeners
      _notifyDeviceChanged(deviceId, updatedDevice);
    }
  }
  
  // Stop broadcasting with a device
  Future<void> stopBroadcasting(String deviceId) async {
    if (_activeDevices.containsKey(deviceId)) {
      final updatedDevice = _activeDevices[deviceId]!.copyWith(
        isBroadcasting: false,
        viewerId: null,
      );
      _activeDevices[deviceId] = updatedDevice;
      
      // Notify listeners
      _notifyDeviceChanged(deviceId, updatedDevice);
    }
  }
  
  // Update device status
  Future<void> updateDeviceStatus(String deviceId, {bool? isActive, bool? isBroadcasting}) async {
    if (_activeDevices.containsKey(deviceId)) {
      final updatedDevice = _activeDevices[deviceId]!.copyWith(
        isActive: isActive,
        isBroadcasting: isBroadcasting,
      );
      _activeDevices[deviceId] = updatedDevice;
      
      // Notify listeners
      _notifyDeviceChanged(deviceId, updatedDevice);
    }
  }
  
  // Get a specific device
  Future<DeviceModel?> getDevice(String deviceId) async {
    // Check if we need to refresh devices
    if (_activeDevices.isEmpty) {
      await getAvailableDevices();
    }
    
    return _activeDevices[deviceId];
  }
  
  // Stream for device changes
  Stream<DeviceModel?> deviceStream(String deviceId) {
    if (!_deviceStreamControllers.containsKey(deviceId)) {
      _deviceStreamControllers[deviceId] = StreamController<DeviceModel?>.broadcast();
    }
    
    // Initial value
    if (_activeDevices.containsKey(deviceId)) {
      _deviceStreamControllers[deviceId]!.add(_activeDevices[deviceId]);
    }
    
    return _deviceStreamControllers[deviceId]!.stream;
  }
  
  // Send a vibration signal
  Future<void> sendVibrationSignal(String deviceId, int count) async {
    final signal = VibrationSignal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      count: count,
      timestamp: DateTime.now(),
    );
    
    _recentSignals.insert(0, signal);
    if (_recentSignals.length > 10) {
      _recentSignals.removeLast();
    }
    
    // Notify listeners
    _notifyVibrationSignal(deviceId, _recentSignals);
  }
  
  // Listen for vibration signals
  Stream<List<VibrationSignal>> vibrationSignalsStream(String deviceId) {
    if (!_signalStreamControllers.containsKey(deviceId)) {
      _signalStreamControllers[deviceId] = StreamController<List<VibrationSignal>>.broadcast();
      
      // Send initial empty list
      _signalStreamControllers[deviceId]!.add([]);
    }
    
    return _signalStreamControllers[deviceId]!.stream;
  }
  
  // Helper to notify device changes
  void _notifyDeviceChanged(String deviceId, DeviceModel? device) {
    if (_deviceStreamControllers.containsKey(deviceId)) {
      _deviceStreamControllers[deviceId]!.add(device);
    }
  }
  
  // Helper to notify vibration signals
  void _notifyVibrationSignal(String deviceId, List<VibrationSignal> signals) {
    if (_signalStreamControllers.containsKey(deviceId)) {
      _signalStreamControllers[deviceId]!.add(signals);
    }
  }
  
  // Clean up resources
  void dispose() {
    for (final controller in _deviceStreamControllers.values) {
      controller.close();
    }
    for (final controller in _signalStreamControllers.values) {
      controller.close();
    }
  }
}

// Device service provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final service = DeviceService();
  ref.onDispose(() => service.dispose());
  return service;
}); 