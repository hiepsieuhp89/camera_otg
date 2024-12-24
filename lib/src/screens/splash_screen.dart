import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/providers/app_update.provider.dart';
import 'package:kyoryo/src/providers/authentication.provider.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

enum SplashScreenStateEnum {
  authError,
  checkingAuth,
  checkingForUpdate,
  loadingData,
  finished,
}

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SplashScreenPageState();
}

class _SplashScreenPageState extends ConsumerState<SplashScreen> {
  SplashScreenStateEnum state = SplashScreenStateEnum.finished;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => performHydration());
  }

  void goToBridgeList() {
    context.replaceRoute(const BridgeListRoute());
  }

  void goToAppUpdate() {
    context.replaceRoute(const AppUpdateRoute());
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> performHydration() async {
    setState(() {
      state = SplashScreenStateEnum.checkingAuth;
    });

    await checkForAuthenticated();

    if (state == SplashScreenStateEnum.authError) return;

    setState(() {
      state = SplashScreenStateEnum.checkingForUpdate;
    });

    await checkForUpdate();

    setState(() {
      state = SplashScreenStateEnum.loadingData;
    });

    await loadData();

    setState(() {
      state = SplashScreenStateEnum.finished;
    });

    goToBridgeList();
  }

  Future<void> loadData() async {
    await Future.wait([
      ref.watch(damageTypesProvider.future),
      ref.read(currentMunicipalityProvider.notifier).fetch()
    ]);
  }

  Future<void> checkForUpdate() async {
    await ref.read(appUpdateProvider.notifier).getLatestVersion();

    if (ref.watch(appUpdateProvider).shoudUpdate) {
      goToAppUpdate();
      return;
    }
  }

  Future<void> checkForAuthenticated() async {
    final isAuthenticated =
        await ref.read(authenticationProvider.notifier).checkAuthenticated();

    if (!isAuthenticated) {
      return ref
          .read(authenticationProvider.notifier)
          .login()
          .catchError((error, stackTrace) {
        setState(() {
          state = SplashScreenStateEnum.authError;
        });
        showErrorMessage(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Image(
          image: AssetImage('assets/images/tsunagu.png'),
          width: 120,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 20),
        if (state == SplashScreenStateEnum.authError)
          IconButton(
              onPressed: () {
                performHydration();
              },
              icon: Icon(Icons.refresh))
        else
          const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          state == SplashScreenStateEnum.checkingAuth
              ? AppLocalizations.of(context)!
                  .splashScreenCheckingForAuthenticated
              : state == SplashScreenStateEnum.checkingForUpdate
                  ? AppLocalizations.of(context)!.splashScreenCheckingForUpdates
                  : state == SplashScreenStateEnum.loadingData
                      ? AppLocalizations.of(context)!.splashScreenLoadingData
                      : '',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    )));
  }
}
