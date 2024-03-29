import 'dart:async';

import 'package:kyoryo/src/models/inspection.dart';
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
  Inspection? build(int bridgeId) {
    return null;
  }

  void addInspectionPointReport(int pointId, InspectionPointReport report) {
    if (state == null) throw Exception('Inspection not started');

    state = state!.copyWith(reports: [...state!.reports, report]);
  }

  void startInspection() {
    state =
        Inspection(reports: [], timestamp: DateTime.now(), bridgeId: bridgeId);
  }

  void clearInspection() {
    state = null;
  }

  bool endInspection() {
    if (state == null) return true;

    int numberOfReports = state!.reports.length;
    int numberOfPoints =
        ref.watch(inspectionPointsProvider(bridgeId)).value?.length ?? 0;

    if (numberOfReports == numberOfPoints) {
      clearInspection();
      return true;
    } else {
      return false;
    }
  }

  Future<void> createReport(int pointId, List<String> capturedPhotoPaths,
      Map<String, dynamic>? metadata) async {
    if (state == null) throw Exception('Inspection not started');

    List<Future<Photo>> photoFutures = capturedPhotoPaths
        .map((path) => ref.read(photoServiceProvider).uploadPhoto(path))
        .toList();

    final uploadedPhotos = await Future.wait(photoFutures);

    // NOTE: This is a temporary workaround to group inspection results by timestamp
    final metadataWithTimestamp = <String, dynamic>{
      ...?metadata,
      'timestamp': state!.timestamp.toIso8601String()
    };

    final report = await ref
        .read(inspectionPointReportServiceProvider)
        .createReport(
            pointId,
            uploadedPhotos.map((photo) => photo.id!).toList(),
            metadataWithTimestamp)
        .then((report) => report.copyWith(photos: uploadedPhotos));

    addInspectionPointReport(pointId, report);
  }
}

@riverpod
int numberOfCreatedReports(NumberOfCreatedReportsRef ref, int bridgeId) {
  return ref.watch(bridgeInspectionProvider(bridgeId))?.reports.length ?? 0;
}
