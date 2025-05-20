import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for WebRTC background service
final webRTCBackgroundServiceProvider = Provider<WebRTCBackgroundService>((ref) {
  return WebRTCBackgroundService();
});

/// Service to manage WebRTC connections in background
class WebRTCBackgroundService {
  static const String _notificationChannelId = 'lavie_webrtc_channel';
  static const String _notificationId = 'lavie_webrtc_notification';
  static const int _notificationIdInt = 888;
  
  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isServiceRunning = false;
  
  /// Initialize the background service
  Future<void> init() async {
    final service = FlutterBackgroundService();
    
    // Check if service is running
    _isServiceRunning = await service.isRunning();
    
    // Configure the service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'La Vie Camera Service',
        initialNotificationContent: 'Camera and WebRTC service is running',
        foregroundServiceNotificationId: _notificationIdInt,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }
  
  /// Start the background service
  Future<void> startService() async {
    // Initialize if not already initialized
    if (!_isServiceRunning) {
      await init();
    }
    
    // Start the service
    await _service.startService();
    _isServiceRunning = true;
  }
  
  /// Stop the background service
  Future<void> stopService() async {
    _service.invoke('stopService');
    _isServiceRunning = false;
  }
  
  /// Send a message to the service
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (_isServiceRunning) {
      _service.invoke('message', message);
    }
  }
  
  /// Listen for events from the service
  Stream<Map<String, dynamic>?> get onEvent => _service.on('event');
  
  /// Check if service is running
  Future<bool> isRunning() async {
    return await _service.isRunning();
  }
}

/// Background service entry point for iOS
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  
  // Handle background tasks on iOS
  return true;
}

/// Background service entry point for Android
@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  
  // Configure as a foreground service on Android
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    
    service.setForegroundNotificationInfo(
      title: 'La Vie Camera Connection',
      content: 'Maintaining camera and WebRTC connections',
    );
  }
  
  // Send back initial event
  service.invoke('event', {'type': 'started', 'timestamp': DateTime.now().toIso8601String()});
  
  // Handle service method calls
  service.on('message').listen((message) {
    if (message != null) {
      final type = message['type'] as String?;
      
      switch (type) {
        case 'webrtc':
          // Handle WebRTC related messages
          _handleWebRTCMessage(service, message);
          break;
          
        case 'stopService':
          service.stopSelf();
          break;
          
        default:
          // Forward message as event
          service.invoke('event', {
            'type': 'echo',
            'data': message,
            'timestamp': DateTime.now().toIso8601String(),
          });
          break;
      }
    }
  });
  
  // Periodic task to keep the service alive
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'La Vie Camera Connection',
        content: 'Running since ${DateTime.now().difference(DateTime.now().subtract(const Duration(seconds: 10))).inSeconds} seconds',
      );
    }
    
    // Ping to prevent app from being killed
    service.invoke('event', {
      'type': 'ping',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });
}

/// Handle WebRTC related messages in the background service
void _handleWebRTCMessage(ServiceInstance service, Map<dynamic, dynamic> message) {
  final action = message['action'] as String?;
  
  switch (action) {
    case 'initialize':
      // Initialize WebRTC connection
      service.invoke('event', {
        'type': 'webrtc',
        'action': 'initialized',
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      break;
      
    case 'start':
      // Start WebRTC connection
      service.invoke('event', {
        'type': 'webrtc',
        'action': 'started',
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      break;
      
    case 'stop':
      // Stop WebRTC connection
      service.invoke('event', {
        'type': 'webrtc',
        'action': 'stopped',
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      break;
      
    default:
      // Unknown action
      service.invoke('event', {
        'type': 'webrtc',
        'action': 'unknown',
        'success': false,
        'error': 'Unknown action: $action',
        'timestamp': DateTime.now().toIso8601String(),
      });
      break;
  }
} 