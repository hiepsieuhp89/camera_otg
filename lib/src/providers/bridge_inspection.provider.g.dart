// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge_inspection.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$numberOfCreatedReportsHash() =>
    r'7e46f12be9e4e4157d53c046946d75ceed7c9352';

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

String _$bridgeInspectionHash() => r'7d6eb2d8967599c095ed11d705e6b951e6793584';

abstract class _$BridgeInspection extends BuildlessNotifier<Inspection?> {
  late final int bridgeId;

  Inspection? build(
    int bridgeId,
  );
}

/// See also [BridgeInspection].
@ProviderFor(BridgeInspection)
const bridgeInspectionProvider = BridgeInspectionFamily();

/// See also [BridgeInspection].
class BridgeInspectionFamily extends Family<Inspection?> {
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
class BridgeInspectionProvider
    extends NotifierProviderImpl<BridgeInspection, Inspection?> {
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
  Inspection? runNotifierBuild(
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
  NotifierProviderElement<BridgeInspection, Inspection?> createElement() {
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

mixin BridgeInspectionRef on NotifierProviderRef<Inspection?> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _BridgeInspectionProviderElement
    extends NotifierProviderElement<BridgeInspection, Inspection?>
    with BridgeInspectionRef {
  _BridgeInspectionProviderElement(super.provider);

  @override
  int get bridgeId => (origin as BridgeInspectionProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
