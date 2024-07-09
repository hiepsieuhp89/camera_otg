import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/services/base.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection.service.g.dart';

@riverpod
InspectionService inspectionService(InspectionServiceRef ref) {
  return InspectionService();
}

class InspectionService extends BaseApiService {
  Future<Inspection> fetchInspection(int inspectionId) async {
    final jsonResponse = await get('inspections/$inspectionId');

    return Inspection.fromJson(jsonResponse);
  }

  Future<InspectionPointReport> createReport(
      {required InspectionPointReport report,
      List<int> photoIds = const []}) async {
    final jsonResponse =
        await post('inspections/${report.inspectionId}/reports', {
      'photos_ids': photoIds,
      'meta_data': report.metadata,
      'preferred_photo_id': report.preferredPhotoId,
      'inspection_point_id': report.inspectionPointId,
      'status': report.toJson()['status']
    });

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Future<Inspection> finishInspection(int inspectionId, bool isFinished) async {
    final jsonResponse = await put('inspections/$inspectionId',
        body: {'is_finished': isFinished});

    return Inspection.fromJson(jsonResponse);
  }
}
