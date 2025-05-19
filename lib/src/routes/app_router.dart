import 'package:auto_route/auto_route.dart';
import 'package:lavie/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:lavie/src/features/auth/presentation/device_pairing_screen.dart';
import 'package:lavie/src/features/auth/presentation/login_screen.dart';
import 'package:lavie/src/features/auth/presentation/splash_screen.dart';
import 'package:lavie/src/features/broadcast/presentation/broadcast_screen.dart';
import 'package:lavie/src/features/viewer/presentation/viewer_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: AdminDashboardRoute.page),
        AutoRoute(page: DevicePairingRoute.page),
        AutoRoute(page: BroadcastRoute.page),
        AutoRoute(page: ViewerRoute.page),
      ];
}
