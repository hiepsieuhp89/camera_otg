import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/app.dart';
import 'src/features/broadcast/data/webrtc_background_service.dart';
import 'src/firebase_options.dart';
import 'src/core/utils/logger_service.dart';

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global logger instance
final LoggerService globalLogger = LoggerService();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('WidgetsFlutterBinding done');
    
    // Initialize our custom logger service for LOCAL logging only
    await globalLogger.initialize();
    await globalLogger.info('Application starting...');
    
    // Setup logging first
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint(
          '${record.level.name}:${record.time}:${record.loggerName}: ${record.message}');
      // Also log to our file logger (not Firebase yet)
      if (record.level == Level.INFO) {
        globalLogger.info('${record.loggerName}: ${record.message}');
      } else if (record.level == Level.WARNING) {
        globalLogger.warning('${record.loggerName}: ${record.message}');
      } else if (record.level == Level.SEVERE) {
        globalLogger.error('${record.loggerName}: ${record.message}');
      } else {
        globalLogger.debug('${record.loggerName}: ${record.message}');
      }
    });

    var log = Logger("Main");

    // Setup error handlers
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log.severe(
        'FlutterError - Catch all',
        "${details.toString()}\nException: ${details.exception}\nLibrary: ${details.library}\nContext: ${details.context}",
        details.stack,
      );
      globalLogger.error('Flutter Error: ${details.exception}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log.severe('PlatformDispatcher - Catch all', error, stack);
      globalLogger.error('Platform Error: $error');
      return true;
    };

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await globalLogger.info('Notifications initialized');
    
    // Request permissions
    await _requestPermissions();
    
    // Initialize background service
    final webRTCBackgroundService = WebRTCBackgroundService();
    await webRTCBackgroundService.init();
    await globalLogger.info('WebRTC background service initialized');
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized');
      log.info('Firebase initialized successfully');
      await globalLogger.info('Firebase initialized successfully');
      
      // Now that Firebase is initialized, enable Firebase logging
      await globalLogger.enableFirebaseLogging();
    } catch (e, stack) {
      log.severe('Failed to initialize Firebase', e, stack);
      await globalLogger.error('Failed to initialize Firebase: $e');
      // You might want to show an error dialog to the user here
    }

    runApp(ProviderScope(
      child: LavieApp(),
    ));
  } catch (e, stack) {
    print('Fatal error during initialization: $e\n$stack');
    // Try to log the error even though initialization might have failed
    try {
      globalLogger.error('Fatal error during initialization: $e');
    } catch (_) {
      // If logging fails, we can't do much but let the app crash
    }
    // You might want to show a fatal error screen here
    rethrow;
  }
}

/// Request necessary permissions
Future<void> _requestPermissions() async {
  // Camera and microphone permissions for WebRTC
  await Permission.camera.request();
  await Permission.microphone.request();
  
  // USB and storage permissions for camera access
  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }
  
  // Notification permission for background service
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  
  await globalLogger.info('Permissions requested');
}
