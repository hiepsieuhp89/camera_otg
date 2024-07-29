import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/providers/app_start_up.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

class KyoryoApp extends ConsumerWidget {
  const KyoryoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);

    return appStartupState.when(
      loading: () => const Loading(),
      error: (error, stackTrace) {
        debugPrint('appStartup error: $error - stack: $stackTrace');

        return Error(
          message: error.toString(),
          onRetry: () => ref.invalidate(appStartupProvider),
        );
      },
      data: (_) => const MainApp(),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});

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

class Error extends StatelessWidget {
  const Error({super.key, required this.message, required this.onRetry});

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

class MainApp extends ConsumerWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var router = ref.watch(appRouterProvider);

    return MaterialApp.router(
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
      routerConfig: router.config(),
    );
  }
}
