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
  Photo? getPreferredPhotoFromReport(InspectionPointReport? report) {
    if (report == null) {
      return null;
    }

    return report.photos
            .firstWhereOrNull((photo) => photo.id == report.preferredPhotoId) ??
        report.photos.first;
  }

  Future<InspectionPointReport> updateReport(
      InspectionPointReport report) async {
    final jsonResponse = await put('reports/${report.id}', body: {
      'photos': report.photos.map((photo) => photo.id).toList(),
      'meta_data': report.metadata,
      'preferred_photo_id': report.preferredPhotoId,
      'inspection_point_id': report.inspectionPointId,
      'is_skipped': report.isSkipped
    });

    return InspectionPointReport.fromJson(jsonResponse);
  }
}
