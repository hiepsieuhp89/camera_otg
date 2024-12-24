// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$municipalitiesHash() => r'70207af0ac80231ccc85b3ae63d333e966f659c3';

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
String _$contractorsHash() => r'c24442d232963ae3038cb07652ccabf76cda8118';

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
String _$damageTypesHash() => r'91d20b6d93355419523907c9ddd0b0705e32b714';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
