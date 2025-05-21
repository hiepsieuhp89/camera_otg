import 'package:auto_route/auto_route.dart';
import 'package:lavie/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:lavie/src/features/auth/presentation/login_screen.dart';
import 'package:lavie/src/features/auth/presentation/splash_screen.dart';
import 'package:lavie/src/features/broadcast/presentation/broadcast_screen.dart';
import 'package:lavie/src/features/camera/presentation/uvc_camera_screen.dart';
import 'package:lavie/src/features/viewer/presentation/viewer_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth routes
        AutoRoute(page: LoginRoute.page, initial: true, path: '/login'),
        AutoRoute(page: SplashRoute.page, path: '/splash'),
        
        // Role-specific main screens
        AutoRoute(page: AdminDashboardRoute.page, path: '/admin'),
        AutoRoute(page: BroadcastRoute.page, path: '/broadcast'),
        AutoRoute(page: ViewerRoute.page, path: '/viewer'),
        
        // UVC Camera test
        AutoRoute(page: UVCCameraRoute.page, path: '/uvc-camera'),
      ];
}

// Extension removed to avoid conflicts with AutoRouterX extension 