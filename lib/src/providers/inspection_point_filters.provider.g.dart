// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point_filters.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bridgeInspectionPointFiltersHash() =>
    r'30b9e13d2a8aece5cbcc3f4adbeef1b4ca656b6d';

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

abstract class _$BridgeInspectionPointFilters
    extends BuildlessAutoDisposeNotifier<InspectionPointFilters> {
  late final int bridgeId;

  InspectionPointFilters build(
    int bridgeId,
  );
}

/// See also [BridgeInspectionPointFilters].
@ProviderFor(BridgeInspectionPointFilters)
const bridgeInspectionPointFiltersProvider =
    BridgeInspectionPointFiltersFamily();

/// See also [BridgeInspectionPointFilters].
class BridgeInspectionPointFiltersFamily
    extends Family<InspectionPointFilters> {
  /// See also [BridgeInspectionPointFilters].
  const BridgeInspectionPointFiltersFamily();

  /// See also [BridgeInspectionPointFilters].
  BridgeInspectionPointFiltersProvider call(
    int bridgeId,
  ) {
    return BridgeInspectionPointFiltersProvider(
      bridgeId,
    );
  }

  @override
  BridgeInspectionPointFiltersProvider getProviderOverride(
    covariant BridgeInspectionPointFiltersProvider provider,
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
  String? get name => r'bridgeInspectionPointFiltersProvider';
}

/// See also [BridgeInspectionPointFilters].
class BridgeInspectionPointFiltersProvider
    extends AutoDisposeNotifierProviderImpl<BridgeInspectionPointFilters,
        InspectionPointFilters> {
  /// See also [BridgeInspectionPointFilters].
  BridgeInspectionPointFiltersProvider(
    int bridgeId,
  ) : this._internal(
          () => BridgeInspectionPointFilters()..bridgeId = bridgeId,
          from: bridgeInspectionPointFiltersProvider,
          name: r'bridgeInspectionPointFiltersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bridgeInspectionPointFiltersHash,
          dependencies: BridgeInspectionPointFiltersFamily._dependencies,
          allTransitiveDependencies:
              BridgeInspectionPointFiltersFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  BridgeInspectionPointFiltersProvider._internal(
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
  InspectionPointFilters runNotifierBuild(
    covariant BridgeInspectionPointFilters notifier,
  ) {
    return notifier.build(
      bridgeId,
    );
  }

  @override
  Override overrideWith(BridgeInspectionPointFilters Function() create) {
    return ProviderOverride(
      origin: this,
      override: BridgeInspectionPointFiltersProvider._internal(
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
  AutoDisposeNotifierProviderElement<BridgeInspectionPointFilters,
      InspectionPointFilters> createElement() {
    return _BridgeInspectionPointFiltersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BridgeInspectionPointFiltersProvider &&
        other.bridgeId == bridgeId;
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
mixin BridgeInspectionPointFiltersRef
    on AutoDisposeNotifierProviderRef<InspectionPointFilters> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _BridgeInspectionPointFiltersProviderElement
    extends AutoDisposeNotifierProviderElement<BridgeInspectionPointFilters,
        InspectionPointFilters> with BridgeInspectionPointFiltersRef {
  _BridgeInspectionPointFiltersProviderElement(super.provider);

  @override
  int get bridgeId => (origin as BridgeInspectionPointFiltersProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
