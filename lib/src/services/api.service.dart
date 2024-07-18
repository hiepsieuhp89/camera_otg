import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/contractor.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/services/api_client.service.dart';

class ApiService {
  final ApiClient apiClient = ApiClient();
  String? _accessToken;

  setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  Map<String, String> getAuthorizationHeader() {
    return {'Authorization': 'Bearer $_accessToken'};
  }

  Future<List<Bridge>> fetchBridges() async {
    final jsonResponse = await apiClient.get('api/mobile/bridges',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((bridge) => Bridge.fromJson(bridge))
        .toList();
  }

  Future<List<InspectionPoint>> fetchInspectionPoints(int brdigeId) async {
    final jsonResponse =
        await apiClient.get('api/mobile/bridges/$brdigeId/inspection_points');

    return (jsonResponse as List)
        .map((inspectionPoint) => InspectionPoint.fromJson(inspectionPoint))
        .toList();
  }

  Future<InspectionPoint> createInspectionPoint(
      InspectionPoint inspectionPoint) async {
    final jsonResponse = await apiClient.post('api/mobile/inspection_points',
        body: inspectionPoint.toJson());

    return InspectionPoint.fromJson(jsonResponse);
  }

  Future<List<Diagram>> fetchDiagrams(int bridgeId) async {
    final jsonResponse =
        await apiClient.get('api/mobile/bridges/$bridgeId/diagrams');

    return (jsonResponse as List)
        .map((diagram) => Diagram.fromJson(diagram))
        .toList();
  }

  Future<Diagram> createDiagram(Diagram diagram) async {
    final jsonResponse = await apiClient.post(
        'api/mobile/bridges/${diagram.bridgeId}/diagrams?photo_id=${diagram.photoId}',
        body: diagram.toJson());

    return Diagram.fromJson(jsonResponse);
  }

  Future<List<Inspection>> fetchInspections(int bridgeId) async {
    final jsonResponse =
        await apiClient.get('api/mobile/bridges/$bridgeId/inspections');

    return (jsonResponse as List)
        .map((inspection) => Inspection.fromJson(inspection))
        .toList();
  }

  Future<InspectionPointReport> updateReport(
      InspectionPointReport report) async {
    final jsonResponse =
        await apiClient.put('api/mobile/reports/${report.id}', body: {
      'photos': report.photos.map((photo) => photo.id).toList(),
      'meta_data': report.metadata,
      'preferred_photo_id': report.preferredPhotoId,
      'inspection_point_id': report.inspectionPointId,
      'status': report.toJson()['status']
    });

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Future<Inspection> fetchInspection(int inspectionId) async {
    final jsonResponse = await apiClient.get('inspections/$inspectionId');

    return Inspection.fromJson(jsonResponse);
  }

  Future<InspectionPointReport> createReport(
      {required InspectionPointReport report,
      List<int> photoIds = const []}) async {
    final jsonResponse = await apiClient
        .post('api/mobile/inspections/${report.inspectionId}/reports', body: {
      'photos_ids': photoIds,
      'meta_data': report.metadata,
      'preferred_photo_id': report.preferredPhotoId,
      'inspection_point_id': report.inspectionPointId,
      'status': report.toJson()['status']
    });

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Future<Inspection> finishInspection(int inspectionId, bool isFinished) async {
    final jsonResponse = await apiClient.put(
        'api/mobile/inspections/$inspectionId',
        body: {'is_finished': isFinished});

    return Inspection.fromJson(jsonResponse);
  }

  Future<Municipality?> getMunicipalityByCode(String code) async {
    final jsonResponse = await apiClient
        .get('api/mobile/municipalities', queryParams: {'code': code});

    if ((jsonResponse as List).isEmpty) {
      return null;
    }

    return Municipality.fromJson((jsonResponse).first);
  }

  Future<List<Municipality>> fetchMunicipalities() async {
    final jsonResponse = await apiClient.get('api/mobile/municipalities');

    return (jsonResponse as List)
        .map((municipality) => Municipality.fromJson(municipality))
        .toList();
  }

  Future<List<Contractor>> fetchContractors() async {
    final jsonResponse = await apiClient.get('api/mobile/contractors');

    return (jsonResponse as List)
        .map((contractor) => Contractor.fromJson(contractor))
        .toList();
  }

  Future<List<DamageType>> fetchDamageTypes() async {
    final jsonResponse = await apiClient.get('api/mobile/get_damage_types');

    return (jsonResponse as List)
        .map((damageType) => DamageType.fromJson(damageType))
        .toList();
  }

  Future<Photo> uploadPhoto(String filePath) async {
    final jsonResponse =
        await apiClient.postSingleFile('api/mobile/photo', filePath);

    return Photo.fromJson(jsonResponse);
  }
}
