import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:kyoryo/src/providers/shared_preferences.provider.dart';
import 'package:kyoryo/src/routing/auth_guard.dart';
import 'package:kyoryo/src/screens/app_update_screen.dart';
import 'package:kyoryo/src/screens/inspection_point_diagram_select_screen.dart';
import 'package:kyoryo/src/screens/splash_screen.dart';
import 'package:kyoryo/src/screens/login_screen.dart';
import 'package:kyoryo/src/screens/bridge_filters_screen.dart';
import 'package:kyoryo/src/screens/bridge_list_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/tab_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/photos_selection_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/photos_comparison_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';
import 'package:kyoryo/src/screens/inspection_point_creation_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  late final AuthGuard _authGuard;

  AppRouter(
    ApiService apiService,
    SharedPreferences sharedPreferences,
  ) {
    _authGuard = AuthGuard(apiService, sharedPreferences);
  }

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: BridgeFiltersRoute.page, guards: [_authGuard]),
        AutoRoute(page: BridgeListRoute.page, guards: [_authGuard]),
        AutoRoute(
            page: BridgeInspectionEvaluationRoute.page, guards: [_authGuard]),
        CustomRoute(page: BridgeInspectionPhotosTabRoute.page, guards: [
          _authGuard
        ], children: [
          AutoRoute(
              page: BridgeInspectionPhotoComparisonRoute.page,
              guards: [_authGuard]),
          AutoRoute(
              page: BridgeInspectionPhotoSelectionRoute.page,
              guards: [_authGuard]),
        ]),
        AutoRoute(page: BridgeInspectionRoute.page, guards: [_authGuard]),
        AutoRoute(
            page: InspectionPointCreationRoute.page, guards: [_authGuard]),
        AutoRoute(
            page: InspectionPointDiagramSelectRoute.page, guards: [_authGuard]),
        AutoRoute(page: TakePictureRoute.page, guards: [_authGuard]),
        AutoRoute(page: AppUpdateRoute.page, guards: [_authGuard]),
      ];
}

final appRouterProvider = Provider((ref) => AppRouter(
      ref.watch(apiServiceProvider),
      ref.watch(sharedPreferencesProvider).requireValue,
    ));
