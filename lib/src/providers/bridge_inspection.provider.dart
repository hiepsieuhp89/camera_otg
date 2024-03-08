import 'dart:async';

import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
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

  Future<void> createReport(
      int pointId, List<String> capturedPhotoPaths) async {
    List<Future<Photo>> photoFutures = capturedPhotoPaths
        .map((path) => ref.read(photoServiceProvider).uploadPhoto(path))
        .toList();

    final photoIds = await Future.wait(photoFutures)
        .then((photos) => photos.map((photo) => photo.id!).toList());

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    final report = await ref
        .read(inspectionPointReportServiceProvider)
        .createReport(pointId, null, photoIds);

    addInspectionPointReport(pointId, report);
  }
}

@riverpod
int numberOfCreatedReports(NumberOfCreatedReportsRef ref, int bridgeId) {
  return ref.watch(bridgeInspectionProvider(bridgeId)).length;
}
