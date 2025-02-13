import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_point_report.service.g.dart';

@riverpod
InspectionPointReportService inspectionPointReportService(Ref ref) {
  return InspectionPointReportService();
}

class InspectionPointReportService {
  InspectionPointReportPhoto? getPreferredPhotoFromReport(
      InspectionPointReport? report) {
    if (report == null || report.photos.isEmpty) {
      return null;
    }

    return report.photos
            .firstWhereOrNull((photo) => photo.sequenceNumber == 1) ??
        report.photos.first;
  }
}
