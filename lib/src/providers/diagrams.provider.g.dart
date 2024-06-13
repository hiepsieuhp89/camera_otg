// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagrams.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagramsHash() => r'94d5e50cd41d2ea10c5047579de87fdd8cafcf0c';

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

abstract class _$Diagrams
    extends BuildlessAutoDisposeAsyncNotifier<List<Diagram>> {
  late final int bridgeId;

  FutureOr<List<Diagram>> build(
    int bridgeId,
  );
}

/// See also [Diagrams].
@ProviderFor(Diagrams)
const diagramsProvider = DiagramsFamily();

/// See also [Diagrams].
class DiagramsFamily extends Family<AsyncValue<List<Diagram>>> {
  /// See also [Diagrams].
  const DiagramsFamily();

  /// See also [Diagrams].
  DiagramsProvider call(
    int bridgeId,
  ) {
    return DiagramsProvider(
      bridgeId,
    );
  }

  @override
  DiagramsProvider getProviderOverride(
    covariant DiagramsProvider provider,
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
  String? get name => r'diagramsProvider';
}

/// See also [Diagrams].
class DiagramsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Diagrams, List<Diagram>> {
  /// See also [Diagrams].
  DiagramsProvider(
    int bridgeId,
  ) : this._internal(
          () => Diagrams()..bridgeId = bridgeId,
          from: diagramsProvider,
          name: r'diagramsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$diagramsHash,
          dependencies: DiagramsFamily._dependencies,
          allTransitiveDependencies: DiagramsFamily._allTransitiveDependencies,
          bridgeId: bridgeId,
        );

  DiagramsProvider._internal(
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
  FutureOr<List<Diagram>> runNotifierBuild(
    covariant Diagrams notifier,
  ) {
    return notifier.build(
      bridgeId,
    );
  }

  @override
  Override overrideWith(Diagrams Function() create) {
    return ProviderOverride(
      origin: this,
      override: DiagramsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<Diagrams, List<Diagram>>
      createElement() {
    return _DiagramsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiagramsProvider && other.bridgeId == bridgeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bridgeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DiagramsRef on AutoDisposeAsyncNotifierProviderRef<List<Diagram>> {
  /// The parameter `bridgeId` of this provider.
  int get bridgeId;
}

class _DiagramsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Diagrams, List<Diagram>>
    with DiagramsRef {
  _DiagramsProviderElement(super.provider);

  @override
  int get bridgeId => (origin as DiagramsProvider).bridgeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
