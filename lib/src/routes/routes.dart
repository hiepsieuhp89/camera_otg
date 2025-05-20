import 'package:auto_route/auto_route.dart';

// Route constants for app navigation
class Routes {
  static const loginRoute = '/login';
  static const splashRoute = '/splash';
  static const adminDashboardRoute = '/admin';
  static const broadcastRoute = '/broadcast';
  static const viewerRoute = '/viewer';
  static const devicePairingRoute = '/device-pairing';
  static const uvcCameraRoute = '/uvc-camera';
}

// Route pages for auto_route
@RoutePage()
class LoginRoute extends AutoRouter {
  const LoginRoute({super.key});
}

@RoutePage()
class AdminDashboardRoute extends AutoRouter {
  const AdminDashboardRoute({super.key});
}

@RoutePage()
class BroadcastRoute extends AutoRouter {
  const BroadcastRoute({super.key});
}

@RoutePage()
class ViewerRoute extends AutoRouter {
  const ViewerRoute({super.key});
}

@RoutePage()
class DevicePairingRoute extends AutoRouter {
  const DevicePairingRoute({super.key});
}

@RoutePage()
class UVCCameraRoute extends AutoRouter {
  const UVCCameraRoute({super.key});
}

// Extension for simplified navigation using named routes
extension AppRouterNavigationHelpers on StackRouter {
  Future<void> navigateToLogin() => navigateNamed(Routes.loginRoute);
  Future<void> navigateToSplash() => navigateNamed(Routes.splashRoute);
  Future<void> navigateToAdmin() => navigateNamed(Routes.adminDashboardRoute);
  Future<void> navigateToBroadcast() => navigateNamed(Routes.broadcastRoute);
  Future<void> navigateToViewer() => navigateNamed(Routes.viewerRoute);
  Future<void> navigateToDevicePairing() => navigateNamed(Routes.devicePairingRoute);
  Future<void> navigateToUVCCamera() => navigateNamed(Routes.uvcCameraRoute);
} 