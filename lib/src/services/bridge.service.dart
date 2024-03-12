import "package:kyoryo/src/models/bridge.dart";
import "package:kyoryo/src/models/inspection_point.dart";
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

  Future<List<InspectionPoint>> fetchInspectionPoints(int brdigeId) async {
    final jsonResponse = await get('bridges/$brdigeId/inspection_points');

    return (jsonResponse as List)
        .map((inspectionPoint) => InspectionPoint.fromJson(inspectionPoint))
        .toList();
  }
}
