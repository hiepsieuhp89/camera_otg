// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_inspection.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$numberOfCreatedReportsHash() =>
    r'8f494ca5a66b8a950749739ff08e7c1289aeb1bb';

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

/// See also [numberOfCreatedReports].
@ProviderFor(numberOfCreatedReports)
const numberOfCreatedReportsProvider = NumberOfCreatedReportsFamily();

/// See also [numberOfCreatedReports].
class NumberOfCreatedReportsFamily extends Family<int> {
  /// See also [numberOfCreatedReports].
  const NumberOfCreatedReportsFamily();

  /// See also [numberOfCreatedReports].
  NumberOfCreatedReportsProvider call(
    int bridgeId,
  ) {
    return NumberOfCreatedReportsProvider(
      bridgeId,
    );
  }

  @override
  NumberOfCreatedReportsProvider getProviderOverride(
    covariant NumberOfCreatedReportsProvider provider,
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
  String? get name => r'numberOfCreatedReportsProvider';
}

/// See also [numberOfCreatedReports].
class NumberOfCreatedReportsProvider extends AutoDisposeProvider<int> {
  /// See also [numberOfCreatedReports].
  NumberOfCreatedReportsProvider(
    int bridgeId,
  ) : this._internal(
          (ref) => numberOfCreatedReports(
            ref as NumberOfCreatedReportsRef,
            bridgeId,
          ),
          from: numberOfCreatedReportsProvider,
          name: r'numberOfCreatedReportsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$numberOfCreatedReportsHash,
          dependencies: NumberOfCreatedReportsFamily._dependencies,
          allTransitiveDependencies:
              NumberOfCreatedReportsFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  NumberOfCreatedReportsProvider._internal(
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
    int Function(NumberOfCreatedReportsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NumberOfCreatedReportsProvider._internal(
        (ref) => create(ref as NumberOfCreatedReportsRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _NumberOfCreatedReportsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NumberOfCreatedReportsProvider &&
        other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NumberOfCreatedReportsRef on AutoDisposeProviderRef<int> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _NumberOfCreatedReportsProviderElement
    extends AutoDisposeProviderElement<int> with NumberOfCreatedReportsRef {
  _NumberOfCreatedReportsProviderElement(super.provider);

  @override
  int get bridgeId => (origin as NumberOfCreatedReportsProvider).bridgeId;
}

String _$isInspectionInProgressHash() =>
    r'6b58529be0ddb10686f5a60d1465a45a7848456f';

/// See also [isInspectionInProgress].
@ProviderFor(isInspectionInProgress)
const isInspectionInProgressProvider = IsInspectionInProgressFamily();

/// See also [isInspectionInProgress].
class IsInspectionInProgressFamily extends Family<bool> {
  /// See also [isInspectionInProgress].
  const IsInspectionInProgressFamily();

  /// See also [isInspectionInProgress].
  IsInspectionInProgressProvider call(
    int bridgeId,
  ) {
    return IsInspectionInProgressProvider(
      bridgeId,
    );
  }

  @override
  IsInspectionInProgressProvider getProviderOverride(
    covariant IsInspectionInProgressProvider provider,
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
  String? get name => r'isInspectionInProgressProvider';
}

/// See also [isInspectionInProgress].
class IsInspectionInProgressProvider extends AutoDisposeProvider<bool> {
  /// See also [isInspectionInProgress].
  IsInspectionInProgressProvider(
    int bridgeId,
  ) : this._internal(
          (ref) => isInspectionInProgress(
            ref as IsInspectionInProgressRef,
            bridgeId,
          ),
          from: isInspectionInProgressProvider,
          name: r'isInspectionInProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isInspectionInProgressHash,
          dependencies: IsInspectionInProgressFamily._dependencies,
          allTransitiveDependencies:
              IsInspectionInProgressFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  IsInspectionInProgressProvider._internal(
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
    bool Function(IsInspectionInProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsInspectionInProgressProvider._internal(
        (ref) => create(ref as IsInspectionInProgressRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsInspectionInProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsInspectionInProgressProvider &&
        other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsInspectionInProgressRef on AutoDisposeProviderRef<bool> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _IsInspectionInProgressProviderElement
    extends AutoDisposeProviderElement<bool> with IsInspectionInProgressRef {
  _IsInspectionInProgressProviderElement(super.provider);

  @override
  int get bridgeId => (origin as IsInspectionInProgressProvider).bridgeId;
}

String _$numberOfPendingReportsHash() =>
    r'287929aa3fa38c8dc6ce012c00eae192b3416e69';

/// See also [numberOfPendingReports].
@ProviderFor(numberOfPendingReports)
const numberOfPendingReportsProvider = NumberOfPendingReportsFamily();

/// See also [numberOfPendingReports].
class NumberOfPendingReportsFamily extends Family<int> {
  /// See also [numberOfPendingReports].
  const NumberOfPendingReportsFamily();

  /// See also [numberOfPendingReports].
  NumberOfPendingReportsProvider call(
    int bridgeId,
  ) {
    return NumberOfPendingReportsProvider(
      bridgeId,
    );
  }

  @override
  NumberOfPendingReportsProvider getProviderOverride(
    covariant NumberOfPendingReportsProvider provider,
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
  String? get name => r'numberOfPendingReportsProvider';
}

/// See also [numberOfPendingReports].
class NumberOfPendingReportsProvider extends AutoDisposeProvider<int> {
  /// See also [numberOfPendingReports].
  NumberOfPendingReportsProvider(
    int bridgeId,
  ) : this._internal(
          (ref) => numberOfPendingReports(
            ref as NumberOfPendingReportsRef,
            bridgeId,
          ),
          from: numberOfPendingReportsProvider,
          name: r'numberOfPendingReportsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$numberOfPendingReportsHash,
          dependencies: NumberOfPendingReportsFamily._dependencies,
          allTransitiveDependencies:
              NumberOfPendingReportsFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  NumberOfPendingReportsProvider._internal(
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
    int Function(NumberOfPendingReportsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NumberOfPendingReportsProvider._internal(
        (ref) => create(ref as NumberOfPendingReportsRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _NumberOfPendingReportsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NumberOfPendingReportsProvider &&
        other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NumberOfPendingReportsRef on AutoDisposeProviderRef<int> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _NumberOfPendingReportsProviderElement
    extends AutoDisposeProviderElement<int> with NumberOfPendingReportsRef {
  _NumberOfPendingReportsProviderElement(super.provider);

  @override
  int get bridgeId => (origin as NumberOfPendingReportsProvider).bridgeId;
}

String _$bridgeInspectionHash() => r'13b11dd9562121f46bebbc64b1e97257d7aa7f65';

abstract class _$BridgeInspection
    extends BuildlessAutoDisposeAsyncNotifier<List<Inspection?>> {
  late final int bridgeId;

  FutureOr<List<Inspection?>> build(
    int bridgeId,
  );
}

/// See also [BridgeInspection].
@ProviderFor(BridgeInspection)
const bridgeInspectionProvider = BridgeInspectionFamily();

/// See also [BridgeInspection].
class BridgeInspectionFamily extends Family<AsyncValue<List<Inspection?>>> {
  /// See also [BridgeInspection].
  const BridgeInspectionFamily();

  /// See also [BridgeInspection].
  BridgeInspectionProvider call(
    int bridgeId,
  ) {
    return BridgeInspectionProvider(
      bridgeId,
    );
  }

  @override
  BridgeInspectionProvider getProviderOverride(
    covariant BridgeInspectionProvider provider,
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
  String? get name => r'bridgeInspectionProvider';
}

/// See also [BridgeInspection].
class BridgeInspectionProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BridgeInspection, List<Inspection?>> {
  /// See also [BridgeInspection].
  BridgeInspectionProvider(
    int bridgeId,
  ) : this._internal(
          () => BridgeInspection()..bridgeId = bridgeId,
          from: bridgeInspectionProvider,
          name: r'bridgeInspectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bridgeInspectionHash,
          dependencies: BridgeInspectionFamily._dependencies,
          allTransitiveDependencies:
              BridgeInspectionFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  BridgeInspectionProvider._internal(
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
  FutureOr<List<Inspection?>> runNotifierBuild(
    covariant BridgeInspection notifier,
  ) {
    return notifier.build(
      bridgeId,
    );
  }

  @override
  Override overrideWith(BridgeInspection Function() create) {
    return ProviderOverride(
      origin: this,
      override: BridgeInspectionProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BridgeInspection, List<Inspection?>>
      createElement() {
    return _BridgeInspectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BridgeInspectionProvider && other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BridgeInspectionRef
    on AutoDisposeAsyncNotifierProviderRef<List<Inspection?>> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _BridgeInspectionProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BridgeInspection,
        List<Inspection?>> with BridgeInspectionRef {
  _BridgeInspectionProviderElement(super.provider);

  @override
  int get bridgeId => (origin as BridgeInspectionProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
