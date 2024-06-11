// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$municipalitiesHash() => r'e8a3af63c1d4ab545a445e3d7c0740fa0b9c2146';

/// See also [Municipalities].
@ProviderFor(Municipalities)
final municipalitiesProvider = AutoDisposeAsyncNotifierProvider<Municipalities,
    List<Municipality>>.internal(
  Municipalities.new,
  name: r'municipalitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$municipalitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Municipalities = AutoDisposeAsyncNotifier<List<Municipality>>;
String _$contractorsHash() => r'be48a276b9090135f4b6792056fd63e6fcc30f90';

/// See also [Contractors].
@ProviderFor(Contractors)
final contractorsProvider =
    AutoDisposeAsyncNotifierProvider<Contractors, List<Contractor>>.internal(
  Contractors.new,
  name: r'contractorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$contractorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Contractors = AutoDisposeAsyncNotifier<List<Contractor>>;
String _$damageTypesHash() => r'350c6e315c8387494757306307ccba7a21f6b0b9';

/// See also [DamageTypes].
@ProviderFor(DamageTypes)
final damageTypesProvider =
    AsyncNotifierProvider<DamageTypes, List<DamageType>>.internal(
  DamageTypes.new,
  name: r'damageTypesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$damageTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DamageTypes = AsyncNotifier<List<DamageType>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
