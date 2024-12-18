import 'package:flutter/material.dart';
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
    log.info('App resumed');
    state = AppLifecycleState.resumed;

    final isAuthenticated = ref.read(authenticationProvider).isAuthenticated;

    if (isAuthenticated) {
      await ref.read(appUpdateProvider.notifier).getLatestVersion();

      final appRouter = ref.read(appRouterProvider);

      if (ref.read(appUpdateProvider).shoudUpdate &&
          appRouter.current.name != AppUpdateRoute.name) {
        ref.read(appRouterProvider).pushNamed(AppUpdateRoute.name);
      }
    }
  }

  void handleAppInactivity() {
    log.info('App inactive');
    state = AppLifecycleState.inactive;
  }

  void handleAppPause() {
    log.info('App paused');
    state = AppLifecycleState.paused;
  }

  void handleAppDetached() {
    log.info('App detached');
    state = AppLifecycleState.detached;
  }

  void handleAppHidden() {
    log.info('App hidden');
    state = AppLifecycleState.hidden;
  }
}
