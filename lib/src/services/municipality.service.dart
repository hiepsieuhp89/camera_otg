import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kyoryo_flutter/src/models/municipality.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'municipality.service.g.dart';

@Riverpod(keepAlive: true)
MunicipalityService municipalityService(MunicipalityServiceRef ref) {
  return MunicipalityService();
}

class MunicipalityService {
  Future<Municipality?> getMunicipalityByCode(String code) async {
    final response = await http
        .get(Uri.http('10.0.2.2:3000', '/municipalities', {'code': code}));

    if (response.statusCode == 200) {
      List<dynamic> jsonArray = json.decode(utf8.decode(response.bodyBytes));

      if (jsonArray.isEmpty) {
        return null;
      }

      return Municipality.fromJson(jsonArray.first);
    } else {
      throw Exception('Failed to load municipality');
    }
  }

  Future<List<Municipality>> fetchMunicipalities() async {
    final response =
        await http.get(Uri.http('10.0.2.2:3000', '/municipalities'));

    if (response.statusCode == 200) {
      List<dynamic> jsonArray = json.decode(utf8.decode(response.bodyBytes));
      return jsonArray
          .map((jsonItem) => Municipality.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception('Failed to load municipality');
    }
  }
}
