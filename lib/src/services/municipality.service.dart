import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/services/base.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'municipality.service.g.dart';

@Riverpod(keepAlive: true)
MunicipalityService municipalityService(MunicipalityServiceRef ref) {
  return MunicipalityService();
}

class MunicipalityService extends BaseApiService {
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
}
