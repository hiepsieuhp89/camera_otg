import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:firebase_core/firebase_core.dart';

import 'src/app.dart';
import 'src/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${record.level.name}:${record.time}:${record.loggerName}: ${record.message}');
  });

  var log = Logger("Main");

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

  runApp(const ProviderScope(
    child: LavieApp(),
  ));
}
