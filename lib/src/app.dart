import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:lavie/src/features/auth/presentation/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lavie/src/firebase_options.dart';

class LavieApp extends ConsumerWidget {
  const LavieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Lavie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Navigator(onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      }),
    );
  }
}
