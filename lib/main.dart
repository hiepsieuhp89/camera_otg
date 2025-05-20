import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/providers/logger_provider.dart';
import 'package:lavie/src/firebase_options.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ProviderScope(
      child: LavieApp(),
    ),
  );
}

class LavieApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<LavieApp> createState() => _LavieAppState();
}

class _LavieAppState extends ConsumerState<LavieApp> {
  final _appRouter = AppRouter();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize Logger
    Future.delayed(Duration.zero, () async {
      final logger = ref.read(loggerProvider);
      await logger.initialize();
      await logger.enableFirebaseLogging();
      logger.info('App started');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lavie',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
