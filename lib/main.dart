import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'src/app.dart';
import 'src/firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('WidgetsFlutterBinding done');
    
    // Setup logging first
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint(
          '${record.level.name}:${record.time}:${record.loggerName}: ${record.message}');
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
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log.severe('PlatformDispatcher - Catch all', error, stack);
      return true;
    };

    // Load environment variables
    // await dotenv.load();
    // print('dotenv loaded');
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized');
      log.info('Firebase initialized successfully');
    } catch (e, stack) {
      log.severe('Failed to initialize Firebase', e, stack);
      // You might want to show an error dialog to the user here
    }

    runApp(ProviderScope(
      child: LavieApp(),
    ));
  } catch (e, stack) {
    print('Fatal error during initialization: $e\\n$stack');
    // You might want to show a fatal error screen here
    rethrow;
  }
}
