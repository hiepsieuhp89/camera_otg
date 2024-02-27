import "package:kyoryo/src/models/bridge.dart";
import "package:kyoryo/src/models/bridge_element.dart";
import "package:kyoryo/src/services/base.service.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part 'bridge.service.g.dart';

@riverpod
BridgeService bridgeService(BridgeServiceRef ref) {
  return BridgeService();
}

class BridgeService extends BaseApiService {
  Future<List<Bridge>> fetchBridges() async {
    final jsonResponse = await get('bridges');

    return (jsonResponse as List)
        .map((bridge) => Bridge.fromJson(bridge))
        .toList();
  }

  Future<List<BridgeElement>> fetchBridgeElements() async {
    final jsonResponse = await get('bridge_elements');

    return (jsonResponse as List)
        .map((bridgeElement) => BridgeElement.fromJson(bridgeElement))
        .toList();
  }
}
