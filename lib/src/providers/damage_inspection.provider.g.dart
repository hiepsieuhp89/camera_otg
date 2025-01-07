// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_inspection.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$damageInspectionHash() => r'4fa6bf0eeb100355c06d185f43049ae35e899739';

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

abstract class _$DamageInspection
    extends BuildlessAutoDisposeAsyncNotifier<DamageInspectionState> {
  late final int bridgeId;

  FutureOr<DamageInspectionState> build(
    int bridgeId,
  );
}

/// See also [DamageInspection].
@ProviderFor(DamageInspection)
const damageInspectionProvider = DamageInspectionFamily();

/// See also [DamageInspection].
class DamageInspectionFamily extends Family<AsyncValue<DamageInspectionState>> {
  /// See also [DamageInspection].
  const DamageInspectionFamily();

  /// See also [DamageInspection].
  DamageInspectionProvider call(
    int bridgeId,
  ) {
    return DamageInspectionProvider(
      bridgeId,
    );
  }

  @override
  DamageInspectionProvider getProviderOverride(
    covariant DamageInspectionProvider provider,
  ) {
    return call(
      provider.bridgeId,
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
  String? get name => r'damageInspectionProvider';
}

/// See also [DamageInspection].
class DamageInspectionProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DamageInspection, DamageInspectionState> {
  /// See also [DamageInspection].
  DamageInspectionProvider(
    int bridgeId,
  ) : this._internal(
          () => DamageInspection()..bridgeId = bridgeId,
          from: damageInspectionProvider,
          name: r'damageInspectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$damageInspectionHash,
          dependencies: DamageInspectionFamily._dependencies,
          allTransitiveDependencies:
              DamageInspectionFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  DamageInspectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bridgeId,
  }) : super.internal();

  final int bridgeId;

  @override
  FutureOr<DamageInspectionState> runNotifierBuild(
    covariant DamageInspection notifier,
  ) {
    return notifier.build(
      bridgeId,
    );
  }

  @override
  Override overrideWith(DamageInspection Function() create) {
    return ProviderOverride(
      origin: this,
      override: DamageInspectionProvider._internal(
        () => create()..bridgeId = bridgeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bridgeId: bridgeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DamageInspection,
      DamageInspectionState> createElement() {
    return _DamageInspectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DamageInspectionProvider && other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DamageInspectionRef
    on AutoDisposeAsyncNotifierProviderRef<DamageInspectionState> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _DamageInspectionProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DamageInspection,
        DamageInspectionState> with DamageInspectionRef {
  _DamageInspectionProviderElement(super.provider);

  @override
  int get bridgeId => (origin as DamageInspectionProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
