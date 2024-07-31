import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kyoryo/src/models/user.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:kyoryo/src/providers/shared_preferences.provider.dart';
import 'package:kyoryo/src/services/api_client.service.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication.provider.g.dart';

@Riverpod(keepAlive: true)
Auth0 auth0(Auth0Ref ref) {
  return Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );
}

final log = Logger('AuthenticationProvider');

@Riverpod(keepAlive: true)
class Authentication extends _$Authentication {
  @override
  AuthenticationState build() {
    return AuthenticationState(isAuthenticated: false);
  }

  Future<void> login() async {
    final auth0 = ref.watch(auth0Provider);
    final credentials = await auth0
        .webAuthentication(scheme: 'kyoryoapp')
        .login(audience: dotenv.env['AUTH0_AUDIENCE']!, scopes: const {
      'openid',
      'profile',
      'email',
    });
    ref.watch(apiServiceProvider).setAccessToken(credentials.accessToken);
    ref
        .read(sharedPreferencesProvider)
        .requireValue
        .setString('access_token', credentials.accessToken);
  }

  Future<void> logout() async {
    ref.read(sharedPreferencesProvider).requireValue.remove('access_token');
    ref.watch(apiServiceProvider).setAccessToken(null);
    await ref
        .watch(auth0Provider)
        .webAuthentication(scheme: 'kyoryoapp')
        .logout();
  }

  Future<bool> checkAuthenticated() async {
    final accessToken = ref
        .read(sharedPreferencesProvider)
        .requireValue
        .getString('access_token');
    bool isAuthenticated;

    User? authenticatedUser;

    try {
      final apiService = ref.watch(apiServiceProvider);

      if (accessToken == null) {
        isAuthenticated = false;
      } else {
        apiService.setAccessToken(accessToken);
        authenticatedUser = await apiService.fetchCurrentUser();
        isAuthenticated = true;
      }
    } on UnauthorizedApiException catch (e, _) {
      isAuthenticated = false;
    } catch (e, stackTrace) {
      log.severe('Error checking authentication', e, stackTrace);
      isAuthenticated = false;
    }

    state = state.copyWith(
        isAuthenticated: isAuthenticated, user: authenticatedUser);

    return isAuthenticated;
  }
}

class AuthenticationState {
  final bool isAuthenticated;
  User? user;

  AuthenticationState({required this.isAuthenticated, this.user});

  AuthenticationState copyWith({bool? isAuthenticated, User? user}) {
    return AuthenticationState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user,
    );
  }
}
