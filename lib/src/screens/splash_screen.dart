import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> performHydration() async {
    await ref
        .read(authenticationProvider.notifier)
        .checkAuthenticated()
        .then((isAuthenticated) {
      if (!isAuthenticated) {
        return goToLogin();
      }

      Future.wait([
        ref.watch(damageTypesProvider.future),
        ref.read(currentMunicipalityProvider.notifier).fetch()
      ]).then((_) {
        goToBridgeList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Image(
      image: AssetImage('assets/images/tsunagu.png'),
      width: 120,
      filterQuality: FilterQuality.high,
    )));
  }
}
