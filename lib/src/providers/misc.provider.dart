import 'package:kyoryo/src/models/contractor.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/services/misc.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'misc.provider.g.dart';

@riverpod
class Municipalities extends _$Municipalities {
  @override
  Future<List<Municipality>> build() {
    return ref.watch(miscServiceProvider).fetchMunicipalities();
  }
}

@riverpod
class Contractors extends _$Contractors {
  @override
  Future<List<Contractor>> build() {
    return ref.watch(miscServiceProvider).fetchContractors();
  }
}

@riverpod
class DamageTypes extends _$DamageTypes {
  @override
  Future<List<DamageType>> build() {
    return ref.watch(miscServiceProvider).fetchDamageTypes();
  }
}
