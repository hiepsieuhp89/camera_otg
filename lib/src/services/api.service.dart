import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/contractor.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/models/user.dart';
import 'package:kyoryo/src/services/api_client.service.dart';
import 'package:logging/logging.dart';
import 'package:kyoryo/src/models/version.dart';

class ApiService {
  final ApiClient apiClient = ApiClient();
  final log = Logger('ApiService');
  String? _accessToken;

  setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  Map<String, String> getAuthorizationHeader() {
    return {'Authorization': 'Bearer $_accessToken'};
  }

  Future<bool> validateAccessToken() async {
    try {
      final jsonResponse = await apiClient.post('auth/token_validation',
          headerParams: getAuthorizationHeader());

      return jsonResponse['auth'] != null;
    } catch (error, stackTrace) {
      log.warning('Error validating access token', error, stackTrace);

      return false;
    }
  }

  Future<User> fetchCurrentUser() async {
    final jsonResponse =
        await apiClient.get('users/me', headerParams: getAuthorizationHeader());

    if (jsonResponse != null && jsonResponse.containsKey('user')) {
      return User.fromJson(jsonResponse['user']);
    } else {
      throw Exception('Invalid response');
    }
  }

  Future<List<Bridge>> fetchBridges() async {
    final jsonResponse = await apiClient.get('api/mobile/bridges',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((bridge) => Bridge.fromJson(bridge))
        .toList();
  }

  Future<List<InspectionPoint>> fetchInspectionPoints(int brdigeId) async {
    final jsonResponse = await apiClient.get(
        'api/mobile/bridges/$brdigeId/inspection_points',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((inspectionPoint) => InspectionPoint.fromJson(inspectionPoint))
        .toList();
  }

  Future<InspectionPoint> createInspectionPoint(
      InspectionPoint inspectionPoint) async {
    final jsonResponse = await apiClient.post('api/mobile/inspection_points',
        body: inspectionPoint.toJson(), headerParams: getAuthorizationHeader());

    return InspectionPoint.fromJson(jsonResponse);
  }

  Future<List<Diagram>> fetchDiagrams(int bridgeId) async {
    final jsonResponse = await apiClient.get(
        'api/mobile/bridges/$bridgeId/diagrams',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((diagram) => Diagram.fromJson(diagram))
        .toList();
  }

  Future<Diagram> createDiagram(Diagram diagram) async {
    final jsonResponse = await apiClient.post(
        'api/mobile/bridges/${diagram.bridgeId}/diagrams?photo_id=${diagram.photoId}',
        body: diagram.toJson(),
        headerParams: getAuthorizationHeader());

    return Diagram.fromJson(jsonResponse);
  }

  Future<List<Inspection>> fetchInspections(int bridgeId) async {
    final jsonResponse = await apiClient.get(
        'api/mobile/bridges/$bridgeId/inspections',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((inspection) => Inspection.fromJson(inspection))
        .toList();
  }

  Future<InspectionPointReport> updateReport(
      InspectionPointReport report) async {
    final jsonResponse = await apiClient.put('api/mobile/reports/${report.id}',
        body: {
          'photos': report.toJson()['photos'],
          'meta_data': report.metadata,
          'inspection_point_id': report.inspectionPointId,
          'status': report.toJson()['status']
        },
        headerParams: getAuthorizationHeader());

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Future<Inspection> fetchInspection(int inspectionId) async {
    final jsonResponse = await apiClient.get(
        'api/mobile/inspections/$inspectionId',
        headerParams: getAuthorizationHeader());

    return Inspection.fromJson(jsonResponse);
  }

  Future<InspectionPointReport> createReport({
    required InspectionPointReport report,
  }) async {
    final jsonResponse = await apiClient.post(
        'api/mobile/inspections/${report.inspectionId}/reports',
        body: {
          'photos': report.toJson()['photos'],
          'meta_data': report.metadata,
          'inspection_point_id': report.inspectionPointId,
          'status': report.toJson()['status']
        },
        headerParams: getAuthorizationHeader());

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Future<Inspection> finishInspection(int inspectionId, bool isFinished) async {
    final jsonResponse = await apiClient.put(
        'api/mobile/inspections/$inspectionId',
        body: {'is_finished': isFinished},
        headerParams: getAuthorizationHeader());

    return Inspection.fromJson(jsonResponse);
  }

  Future<Municipality?> getMunicipalityByCode(String code) async {
    final jsonResponse = await apiClient.get('api/mobile/municipalities',
        queryParams: {'code': code}, headerParams: getAuthorizationHeader());

    if ((jsonResponse as List).isEmpty) {
      return null;
    }

    return Municipality.fromJson((jsonResponse).first);
  }

  Future<List<Municipality>> fetchMunicipalities() async {
    final jsonResponse = await apiClient.get('api/mobile/municipalities',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((municipality) => Municipality.fromJson(municipality))
        .toList();
  }

  Future<List<Contractor>> fetchContractors() async {
    final jsonResponse = await apiClient.get('api/mobile/contractors',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((contractor) => Contractor.fromJson(contractor))
        .toList();
  }

  Future<List<DamageType>> fetchDamageTypes() async {
    final jsonResponse = await apiClient.get('api/mobile/get_damage_types',
        headerParams: getAuthorizationHeader());

    return (jsonResponse as List)
        .map((damageType) => DamageType.fromJson(damageType))
        .toList();
  }

  Future<Photo> uploadPhoto(String filePath) async {
    final jsonResponse = await apiClient.postSingleFile(
        'api/mobile/photo', filePath,
        headerParams: getAuthorizationHeader());

    return Photo.fromJson(jsonResponse);
  }

  Future<VersionByEnvironment> fetchVersions() async {
    final jsonResponse = await apiClient.get('api/mobile/versions',
        headerParams: getAuthorizationHeader());

    return VersionByEnvironment.fromJson(jsonResponse);
  }

  Future<InspectionPoint> updateInspectionPoint(
      InspectionPoint inspectionPoint) async {
    final jsonResponse = await apiClient.put(
        'api/mobile/inspection_points/${inspectionPoint.id}',
        body: inspectionPoint.toJson(),
        headerParams: getAuthorizationHeader());

    return InspectionPoint.fromJson(jsonResponse);
  }
}
