// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagram_inspection.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diagramInspectionHash() => r'ea0808560f50d1871ecdc267da2c4dc8bb06e028';

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

abstract class _$DiagramInspection
    extends BuildlessAutoDisposeAsyncNotifier<DiagramInspectionState> {
  late final Diagram diagram;

  FutureOr<DiagramInspectionState> build(
    Diagram diagram,
  );
}

/// See also [DiagramInspection].
@ProviderFor(DiagramInspection)
const diagramInspectionProvider = DiagramInspectionFamily();

/// See also [DiagramInspection].
class DiagramInspectionFamily
    extends Family<AsyncValue<DiagramInspectionState>> {
  /// See also [DiagramInspection].
  const DiagramInspectionFamily();

  /// See also [DiagramInspection].
  DiagramInspectionProvider call(
    Diagram diagram,
  ) {
    return DiagramInspectionProvider(
      diagram,
    );
  }

  @override
  DiagramInspectionProvider getProviderOverride(
    covariant DiagramInspectionProvider provider,
  ) {
    return call(
      provider.diagram,
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
  String? get name => r'diagramInspectionProvider';
}

/// See also [DiagramInspection].
class DiagramInspectionProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DiagramInspection, DiagramInspectionState> {
  /// See also [DiagramInspection].
  DiagramInspectionProvider(
    Diagram diagram,
  ) : this._internal(
          () => DiagramInspection()..diagram = diagram,
          from: diagramInspectionProvider,
          name: r'diagramInspectionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$diagramInspectionHash,
          dependencies: DiagramInspectionFamily._dependencies,
          allTransitiveDependencies:
              DiagramInspectionFamily._allTransitiveDependencies,
          diagram: diagram,
        );

  DiagramInspectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.diagram,
  }) : super.internal();

  final Diagram diagram;

  @override
  FutureOr<DiagramInspectionState> runNotifierBuild(
    covariant DiagramInspection notifier,
  ) {
    return notifier.build(
      diagram,
    );
  }

  @override
  Override overrideWith(DiagramInspection Function() create) {
    return ProviderOverride(
      origin: this,
      override: DiagramInspectionProvider._internal(
        () => create()..diagram = diagram,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        diagram: diagram,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DiagramInspection,
      DiagramInspectionState> createElement() {
    return _DiagramInspectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiagramInspectionProvider && other.diagram == diagram;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, diagram.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiagramInspectionRef
    on AutoDisposeAsyncNotifierProviderRef<DiagramInspectionState> {
  /// The parameter `diagram` of this provider.
  Diagram get diagram;
}

class _DiagramInspectionProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DiagramInspection,
        DiagramInspectionState> with DiagramInspectionRef {
  _DiagramInspectionProviderElement(super.provider);

  @override
  Diagram get diagram => (origin as DiagramInspectionProvider).diagram;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
