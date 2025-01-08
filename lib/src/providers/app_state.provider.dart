import 'package:flutter/material.dart';
import 'package:kyoryo/src/providers/app_router.provider.dart';
import 'package:kyoryo/src/providers/app_update.provider.dart';
import 'package:kyoryo/src/providers/authentication.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.provider.g.dart';

final log = Logger('AppState');

@Riverpod(keepAlive: true)
class AppState extends _$AppState {
  @override
  AppLifecycleState build() {
    return AppLifecycleState.resumed;
  }

  void handleAppResume() async {
    state = AppLifecycleState.resumed;

    final isAuthenticated = ref.read(authenticationProvider).isAuthenticated;
    final appRouter = ref.read(appRouterProvider);

    if (isAuthenticated &&
        appRouter.current.name != AppUpdateRoute.name &&
        appRouter.current.name != SplashRoute.name &&
        ref.read(appUpdateProvider).shouldCheckForUpdate) {
      await ref.read(appUpdateProvider.notifier).getLatestVersion();

      if (ref.read(appUpdateProvider).isOutdated) {
        ref.read(appRouterProvider).pushNamed(AppUpdateRoute.name);
      }
    }
  }

  void handleAppInactivity() {
    state = AppLifecycleState.inactive;
  }

  void handleAppPause() {
    state = AppLifecycleState.paused;
  }

  void handleAppDetached() {
    state = AppLifecycleState.detached;
  }

  void handleAppHidden() {
    log.info('App hidden');
    state = AppLifecycleState.hidden;
  }
}
