import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/municipality.dart';

part 'municipalitiy.provider.g.dart';

@riverpod
Future<List<Municipality>> municipalities(MunicipalitiesRef ref) async {
  final response = await http.get(Uri.http('10.0.2.2:3000', '/municipalities'));

  if (response.statusCode == 200) {
    List<dynamic> jsonArray = json.decode(response.body);
    List<Municipality> items =
        jsonArray.map((jsonItem) => Municipality.fromJson(jsonItem)).toList();

    return items;
  } else {
    throw Exception('Failed to load municipalities');
  }
}
