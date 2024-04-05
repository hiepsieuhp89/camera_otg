import "package:kyoryo/src/models/bridge.dart";
import "package:kyoryo/src/models/diagram.dart";
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

  Future<List<InspectionPoint>> fetchInspectionPoints(int brdigeId,
      {String? timestamp}) async {
    final jsonResponse = await get(
        'bridges/$brdigeId/inspection_points${timestamp != null ? '?timestamp=$timestamp' : ''}');

    return (jsonResponse as List)
        .map((inspectionPoint) => InspectionPoint.fromJson(inspectionPoint))
        .toList();
  }

  Future<InspectionPoint> createInspectionPoint(
      InspectionPoint inspectionPoint) async {
    final jsonResponse =
        await post('inspection_points', inspectionPoint.toJson());

    return InspectionPoint.fromJson(jsonResponse);
  }

  Future<List<Diagram>> fetchDiagrams(int bridgeId) async {
    final jsonResponse = await get('bridges/$bridgeId/diagrams');

    return (jsonResponse as List)
        .map((diagram) => Diagram.fromJson(diagram))
        .toList();
  }

  Future<Diagram> createDiagram(Diagram diagram) async {
    final jsonResponse = await post(
        'bridges/${diagram.bridgeId}/diagrams?photo_id=${diagram.photoId}',
        diagram.toJson());

    return Diagram.fromJson(jsonResponse);
  }
}
