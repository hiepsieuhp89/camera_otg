// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vibration_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vibrationServiceHash() => r'58bf81afcfe11405bbe3f3f0faeafa58a303216b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [vibrationService].
@ProviderFor(vibrationService)
const vibrationServiceProvider = VibrationServiceFamily();

/// See also [vibrationService].
class VibrationServiceFamily extends Family<VibrationService> {
  /// See also [vibrationService].
  const VibrationServiceFamily();

  /// See also [vibrationService].
  VibrationServiceProvider call(
    String userId,
  ) {
    return VibrationServiceProvider(
      userId,
    );
  }

  @override
  VibrationServiceProvider getProviderOverride(
    covariant VibrationServiceProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vibrationServiceProvider';
}

/// See also [vibrationService].
class VibrationServiceProvider extends AutoDisposeProvider<VibrationService> {
  /// See also [vibrationService].
  VibrationServiceProvider(
    String userId,
  ) : this._internal(
          (ref) => vibrationService(
            ref as VibrationServiceRef,
            userId,
          ),
          from: vibrationServiceProvider,
          name: r'vibrationServiceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vibrationServiceHash,
          dependencies: VibrationServiceFamily._dependencies,
          allTransitiveDependencies:
              VibrationServiceFamily._allTransitiveDependencies,
          userId: userId,
        );

  VibrationServiceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    VibrationService Function(VibrationServiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VibrationServiceProvider._internal(
        (ref) => create(ref as VibrationServiceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<VibrationService> createElement() {
    return _VibrationServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VibrationServiceProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VibrationServiceRef on AutoDisposeProviderRef<VibrationService> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _VibrationServiceProviderElement
    extends AutoDisposeProviderElement<VibrationService>
    with VibrationServiceRef {
  _VibrationServiceProviderElement(super.provider);

  @override
  String get userId => (origin as VibrationServiceProvider).userId;
}

String _$vibrationControllerHash() =>
    r'141b28747536bf921f2f9cabc91c5bd7429427d0';

/// See also [VibrationController].
@ProviderFor(VibrationController)
final vibrationControllerProvider =
    NotifierProvider<VibrationController, bool>.internal(
  VibrationController.new,
  name: r'vibrationControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vibrationControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VibrationController = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
