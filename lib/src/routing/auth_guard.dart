import 'package:auto_route/auto_route.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/services/api.service.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends AutoRouteGuard {
  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;
  final _log = Logger("AuthGuard");

  AuthGuard(this._apiService, this._sharedPreferences);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    resolver.next(true);
    final accessToken = _sharedPreferences.getString('access_token');

    if (accessToken == null) {
      _log.info("No access token, User is not authenticated");
      router.replaceAll([const SplashRoute()]);
      return;
    }

    _apiService.setAccessToken(accessToken);
    final isAuthenticated = await _apiService.validateAccessToken();

    if (isAuthenticated) {
      _log.info("User is authenticated");
    } else {
      _log.info("User is not authenticated");
      router.replaceAll([const SplashRoute()]);
    }
  }
}
