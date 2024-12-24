import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/providers/app_router.provider.dart';
import 'package:kyoryo/src/providers/app_start_up.provider.dart';
import 'package:kyoryo/src/providers/app_state.provider.dart';

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

class MainApp extends ConsumerStatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MainAppState();
}

class MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('AppLifecycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(appStateProvider.notifier).handleAppResume();
        break;
      case AppLifecycleState.detached:
        ref.read(appStateProvider.notifier).handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        ref.read(appStateProvider.notifier).handleAppHidden();
        break;
      case AppLifecycleState.paused:
        ref.read(appStateProvider.notifier).handleAppPause();
        break;
      case AppLifecycleState.inactive:
        ref.read(appStateProvider.notifier).handleAppInactivity();
        break;
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
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
