import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/routing/auth_guard.dart';
import 'package:kyoryo/src/screens/app_update_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection/all_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection/damage_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection/present_condition_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection/tab_screen.dart';
import 'package:kyoryo/src/screens/diagram_inspection_screen.dart';
import 'package:kyoryo/src/screens/inspection_point_diagram_select_screen.dart';
import 'package:kyoryo/src/screens/points_inspection_screen.dart';
import 'package:kyoryo/src/screens/splash_screen.dart';
import 'package:kyoryo/src/screens/bridge_filters_screen.dart';
import 'package:kyoryo/src/screens/bridge_list_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/tab_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/photos_selection_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photos/photos_comparison_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kyoryo/src/screens/inspection_point_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class KyoryoAppRouter extends RootStackRouter {
  late final AuthGuard _authGuard;

  KyoryoAppRouter(
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
        AutoRoute(page: BridgeFiltersRoute.page, guards: [_authGuard]),
        AutoRoute(
          page: BridgeListRoute.page,
          guards: [_authGuard],
        ),
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
        CustomRoute(page: BridgeInspectionTabRoute.page, guards: [
          _authGuard
        ], children: [
          AutoRoute(page: BridgeInspectionAllRoute.page, guards: [_authGuard]),
          AutoRoute(
              page: BridgeInspectionDamageRoute.page, guards: [_authGuard]),
          AutoRoute(
              page: BridgeInspectionPresentConditionRoute.page,
              guards: [_authGuard]),
        ]),
        AutoRoute(page: PointsInspectionRoute.page, guards: [_authGuard]),
        AutoRoute(page: DiagramInspectionRoute.page, guards: [_authGuard]),
        AutoRoute(
            page: InspectionPointDiagramSelectRoute.page, guards: [_authGuard]),
        AutoRoute(page: TakePictureRoute.page, guards: [_authGuard]),
        AutoRoute(page: AppUpdateRoute.page, guards: [_authGuard]),
        AutoRoute(page: InspectionPointRoute.page, guards: [_authGuard]),
      ];
}
