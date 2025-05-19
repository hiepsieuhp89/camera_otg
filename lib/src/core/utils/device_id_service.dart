import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'device_id_service.g.dart';

/// Service to manage device identification
class DeviceIdService {
  static const String _deviceIdKey = 'lavie_device_id';
  
  /// Get the device ID, creating a new one if it doesn't exist
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null) {
      // Generate a new device ID
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    
    return deviceId;
  }
}

@riverpod
DeviceIdService deviceIdService(DeviceIdServiceRef ref) {
  return DeviceIdService();
}

@riverpod
Future<String> deviceId(DeviceIdRef ref) async {
  final service = ref.watch(deviceIdServiceProvider);
  return service.getDeviceId();
}
