// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auth0Hash() => r'3c32bc9661bdc199d7aecba3a8f8d8d85c861456';

/// See also [auth0].
@ProviderFor(auth0)
final auth0Provider = Provider<Auth0>.internal(
  auth0,
  name: r'auth0Provider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$auth0Hash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef Auth0Ref = ProviderRef<Auth0>;
String _$authenticationHash() => r'bf1724a1650013c123d949f598980f756bb6245c';

/// See also [Authentication].
@ProviderFor(Authentication)
final authenticationProvider =
    NotifierProvider<Authentication, AuthenticationState>.internal(
  Authentication.new,
  name: r'authenticationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authenticationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Authentication = Notifier<AuthenticationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
