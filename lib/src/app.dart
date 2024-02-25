import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/screens/bridge_details_screen.dart';
import 'package:kyoryo/src/screens/bridge_filters_screen.dart';
import 'package:kyoryo/src/screens/bridge_list_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';

import 'providers/app_start_up.provider.dart';

class KyoryoApp extends ConsumerWidget {
  const KyoryoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);

    return appStartupState.when(
      loading: () => const LoadingApp(),
      error: (error, stackTrace) => ErrorApp(
        message: error.toString(),
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
      data: (_) => const MainApp(),
    );
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key, required this.message, required this.onRetry});

  final String message;
  final Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(message),
              IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh))
            ])),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case BridgeFiltersScreen.routeName:
                return const BridgeFiltersScreen();
              case BridgeDetailsScreen.routeName:
                return const BridgeDetailsScreen();
              case TakePictureScreen.routeName:
                return const TakePictureScreen();
              case BridgeListScreen.routeName:
              default:
                return const BridgeListScreen();
            }
          },
        );
      },
    );
  }
}
