// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_points.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredInspectionPointsHash() =>
    r'd43d8ae8a2a1b85c14337a1593c48fabcd801654';

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

/// See also [filteredInspectionPoints].
@ProviderFor(filteredInspectionPoints)
const filteredInspectionPointsProvider = FilteredInspectionPointsFamily();

/// See also [filteredInspectionPoints].
class FilteredInspectionPointsFamily
    extends Family<AsyncValue<List<InspectionPoint>>> {
  /// See also [filteredInspectionPoints].
  const FilteredInspectionPointsFamily();

  /// See also [filteredInspectionPoints].
  FilteredInspectionPointsProvider call(
    int bridgeId,
  ) {
    return FilteredInspectionPointsProvider(
      bridgeId,
    );
  }

  @override
  FilteredInspectionPointsProvider getProviderOverride(
    covariant FilteredInspectionPointsProvider provider,
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
  String? get name => r'filteredInspectionPointsProvider';
}

/// See also [filteredInspectionPoints].
class FilteredInspectionPointsProvider
    extends AutoDisposeFutureProvider<List<InspectionPoint>> {
  /// See also [filteredInspectionPoints].
  FilteredInspectionPointsProvider(
    int bridgeId,
  ) : this._internal(
          (ref) => filteredInspectionPoints(
            ref as FilteredInspectionPointsRef,
            bridgeId,
          ),
          from: filteredInspectionPointsProvider,
          name: r'filteredInspectionPointsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredInspectionPointsHash,
          dependencies: FilteredInspectionPointsFamily._dependencies,
          allTransitiveDependencies:
              FilteredInspectionPointsFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  FilteredInspectionPointsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<InspectionPoint>> Function(
            FilteredInspectionPointsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredInspectionPointsProvider._internal(
        (ref) => create(ref as FilteredInspectionPointsRef),
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
  AutoDisposeFutureProviderElement<List<InspectionPoint>> createElement() {
    return _FilteredInspectionPointsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredInspectionPointsProvider &&
        other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredInspectionPointsRef
    on AutoDisposeFutureProviderRef<List<InspectionPoint>> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _FilteredInspectionPointsProviderElement
    extends AutoDisposeFutureProviderElement<List<InspectionPoint>>
    with FilteredInspectionPointsRef {
  _FilteredInspectionPointsProviderElement(super.provider);

  @override
  int get bridgeId => (origin as FilteredInspectionPointsProvider).bridgeId;
}

String _$inspectionPointsHash() => r'a60fcebf4aa1ce66a35b170d89bb8b70981a4ccd';

abstract class _$InspectionPoints
    extends BuildlessAutoDisposeAsyncNotifier<List<InspectionPoint>> {
  late final int bridgeId;

  FutureOr<List<InspectionPoint>> build(
    int bridgeId,
  );
}

/// See also [InspectionPoints].
@ProviderFor(InspectionPoints)
const inspectionPointsProvider = InspectionPointsFamily();

/// See also [InspectionPoints].
class InspectionPointsFamily extends Family<AsyncValue<List<InspectionPoint>>> {
  /// See also [InspectionPoints].
  const InspectionPointsFamily();

  /// See also [InspectionPoints].
  InspectionPointsProvider call(
    int bridgeId,
  ) {
    return InspectionPointsProvider(
      bridgeId,
    );
  }

  @override
  InspectionPointsProvider getProviderOverride(
    covariant InspectionPointsProvider provider,
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
  String? get name => r'inspectionPointsProvider';
}

/// See also [InspectionPoints].
class InspectionPointsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    InspectionPoints, List<InspectionPoint>> {
  /// See also [InspectionPoints].
  InspectionPointsProvider(
    int bridgeId,
  ) : this._internal(
          () => InspectionPoints()..bridgeId = bridgeId,
          from: inspectionPointsProvider,
          name: r'inspectionPointsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inspectionPointsHash,
          dependencies: InspectionPointsFamily._dependencies,
          allTransitiveDependencies:
              InspectionPointsFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  InspectionPointsProvider._internal(
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
  FutureOr<List<InspectionPoint>> runNotifierBuild(
    covariant InspectionPoints notifier,
  ) {
    return notifier.build(
      bridgeId,
    );
  }

  @override
  Override overrideWith(InspectionPoints Function() create) {
    return ProviderOverride(
      origin: this,
      override: InspectionPointsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<InspectionPoints,
      List<InspectionPoint>> createElement() {
    return _InspectionPointsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InspectionPointsProvider && other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InspectionPointsRef
    on AutoDisposeAsyncNotifierProviderRef<List<InspectionPoint>> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _InspectionPointsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InspectionPoints,
        List<InspectionPoint>> with InspectionPointsRef {
  _InspectionPointsProviderElement(super.provider);

  @override
  int get bridgeId => (origin as InspectionPointsProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
