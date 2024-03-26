import 'dart:async';

import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/services/photo.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_inspection.provider.g.dart';

@riverpod
class BridgeInspection extends _$BridgeInspection {
  @override
  Map<int, InspectionPointReport> build(int bridgeId) {
    return {};
  }

  void addInspectionPointReport(int pointId, InspectionPointReport report) {
    final reports = {...state};
    reports[pointId] = report;
    state = reports;
  }

  void clearInspectionPointReport(int pointId) {
    final reports = {...state};
    reports.remove(pointId);
    state = reports;
  }

  void clearInspection() {
    state = {};
  }

  bool endInspection() {
    int numberOfReports = state.length;
    int numberOfPoints =
        ref.watch(inspectionPointsProvider(bridgeId)).value?.length ?? 0;

    if (numberOfReports == numberOfPoints) {
      clearInspection();
      return true;
    } else {
      return false;
    }
  }

  Future<void> createReport(
      int pointId, List<String> capturedPhotoPaths, Object? metadata) async {
    List<Photo> uploadedPhotos = [];

    for (var path in capturedPhotoPaths) {
      final photo = await ref.read(photoServiceProvider).uploadPhoto(path);
      uploadedPhotos.add(photo);
    }

    final report = await ref
        .read(inspectionPointReportServiceProvider)
        .createReport(pointId,
            uploadedPhotos.map((photo) => photo.id!).toList(), metadata)
        .then((report) => report.copyWith(photos: uploadedPhotos));

    addInspectionPointReport(pointId, report);
  }
}

@riverpod
int numberOfCreatedReports(NumberOfCreatedReportsRef ref, int bridgeId) {
  return ref.watch(bridgeInspectionProvider(bridgeId)).length;
}
