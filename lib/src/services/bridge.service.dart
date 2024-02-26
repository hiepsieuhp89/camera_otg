import "dart:convert";

import "package:http/http.dart" as http;
import "package:kyoryo/src/models/bridge.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part 'bridge.service.g.dart';

@riverpod
BridgeService bridgeService(BridgeServiceRef ref) {
  return BridgeService();
}

class BridgeService {
  Future<List<Bridge>> fetchBridges() async {
    final response = await http.get(Uri.http('10.0.2.2:3000', '/bridges'));

    if (response.statusCode == 200) {
      List<dynamic> jsonArray = json.decode(utf8.decode(response.bodyBytes));
      return jsonArray.map((jsonItem) => Bridge.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to get bridges');
    }
  }
}
