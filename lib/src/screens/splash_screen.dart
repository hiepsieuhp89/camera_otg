import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/providers/app_update.provider.dart';
import 'package:kyoryo/src/providers/authentication.provider.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SplashScreenPageState();
}

class _SplashScreenPageState extends ConsumerState<SplashScreen> {
  String message = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => performHydration());
  }

  void goToLogin() {
    context.replaceRoute(const LoginRoute());
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
    final loadingDataMessage =
        AppLocalizations.of(context)!.splashScreenLoadingData;
    final checkingAuthMessage =
        AppLocalizations.of(context)!.splashScreenCheckingForAuthenticated;
    final checkingForUpdateMessage =
        AppLocalizations.of(context)!.splashScreenCheckingForUpdates;

    setMessage(checkingAuthMessage);

    await checkForAuthenticated();

    setMessage(checkingForUpdateMessage);

    final shouldUpdate = await checkForUpdate();

    if (shouldUpdate) {
      goToAppUpdate();
      return;
    }

    setMessage(loadingDataMessage);

    await loadData();

    goToBridgeList();
  }

  void setMessage(string) {
    setState(() {
      message = string;
    });
  }

  Future<void> loadData() async {
    await Future.wait([
      ref.watch(damageTypesProvider.future),
      ref.read(currentMunicipalityProvider.notifier).fetch()
    ]);
  }

  Future<bool> checkForUpdate() async {
    await ref.read(appUpdateProvider.notifier).getLatestVersion();

    final appUpdate = ref.watch(appUpdateProvider);

    return appUpdate.shoudUpdate;
  }

  Future<void> checkForAuthenticated() async {
    final isAuthenticated =
        await ref.read(authenticationProvider.notifier).checkAuthenticated();

    if (!isAuthenticated) {
      setMessage('');
      return ref.read(authenticationProvider.notifier).login().then((_) {
        return performHydration();
      }).catchError((error, stackTrace) {
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
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    )));
  }
}
