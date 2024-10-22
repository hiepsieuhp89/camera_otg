import 'package:collection/collection.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_point_report.service.g.dart';

@riverpod
InspectionPointReportService inspectionPointReportService(
    InspectionPointReportServiceRef ref) {
  return InspectionPointReportService();
}

class InspectionPointReportService {
  InspectionPointReportPhoto? getPreferredPhotoFromReport(
      InspectionPointReport? report) {
    if (report == null) {
      return null;
    }

    return report.photos
            .firstWhereOrNull((photo) => photo.sequenceNumber == 1) ??
        report.photos.first;
  }
}
