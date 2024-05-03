import 'package:collection/collection.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/services/base.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_point_report.service.g.dart';

@riverpod
InspectionPointReportService inspectionPointReportService(
    InspectionPointReportServiceRef ref) {
  return InspectionPointReportService();
}

class InspectionPointReportService extends BaseApiService {
  Future<InspectionPointReport> createReport(
      int pointId, List<int> photoIds, Object? metadata) async {
    final jsonResponse = await post('inspection_points/$pointId/reports', {
      'date': DateTime.now().toIso8601String(),
      'photos_ids': photoIds,
      'meta_data': metadata
    });

    return InspectionPointReport.fromJson(jsonResponse);
  }

  Photo? getPreferredPhotoFromReport(InspectionPointReport? report) {
    if (report == null) {
      return null;
    }

    return report.photos
            .firstWhereOrNull((photo) => photo.id == report.preferredPhotoId) ??
        report.photos.first;
  }
}
