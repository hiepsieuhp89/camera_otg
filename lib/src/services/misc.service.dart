import 'package:kyoryo/src/models/contractor.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/services/base.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'misc.service.g.dart';

@Riverpod(keepAlive: true)
MiscService miscService(MiscServiceRef ref) {
  return MiscService();
}

class MiscService extends BaseApiService {
  Future<Municipality?> getMunicipalityByCode(String code) async {
    final jsonResponse = await get('municipalities', query: {'code': code});

    if ((jsonResponse as List).isEmpty) {
      return null;
    }

    return Municipality.fromJson((jsonResponse).first);
  }

  Future<List<Municipality>> fetchMunicipalities() async {
    final jsonResponse = await get('municipalities');

    return (jsonResponse as List)
        .map((municipality) => Municipality.fromJson(municipality))
        .toList();
  }

  Future<List<Contractor>> fetchContractors() async {
    final jsonResponse = await get('contractors');

    return (jsonResponse as List)
        .map((contractor) => Contractor.fromJson(contractor))
        .toList();
  }

  Future<List<DamageType>> fetchDamageTypes() async {
    final jsonResponse = await get('get_damage_types');

    return (jsonResponse as List)
        .map((damageType) => DamageType.fromJson(damageType))
        .toList();
  }
}
