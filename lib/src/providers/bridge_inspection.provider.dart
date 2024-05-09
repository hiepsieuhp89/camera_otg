import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:kyoryo/src/services/inspection.service.dart';
import 'package:kyoryo/src/services/photo.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_inspection.provider.g.dart';

@riverpod
class BridgeInspection extends _$BridgeInspection {
  @override
  Future<List<Inspection?>> build(int bridgeId) async {
    final inspections =
        await ref.read(bridgeServiceProvider).fetchInspections(bridgeId);

    Inspection? latestActiveInspection;
    Inspection? latestFinishedInspection;

    for (var inspection in inspections) {
      if (!inspection.isFinished) {
        latestActiveInspection = inspection;
        break;
      }
    }

    for (var inspection in inspections.reversed) {
      if (inspection.isFinished) {
        latestFinishedInspection = inspection;
        break;
      }
    }

    List<Inspection?> inspectionsToReturn = [];

    if (latestFinishedInspection != null) {
      final inspection = await ref
          .read(inspectionServiceProvider)
          .fetchInspection(latestFinishedInspection.id!);

      inspectionsToReturn.add(inspection);
    } else {
      inspectionsToReturn.add(null);
    }

    if (latestActiveInspection != null) {
      final inspection = await ref
          .read(inspectionServiceProvider)
          .fetchInspection(latestActiveInspection.id!);

      inspectionsToReturn.add(inspection);
    } else {
      inspectionsToReturn.add(null);
    }

    return inspectionsToReturn;
  }

  Future<void> createReport(
      {required int pointId,
      required List<String> capturedPhotoPaths,
      Map<String, dynamic>? metadata,
      int? preferredPhotoIndex}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    int? preferredPhotoId;

    List<Future<Photo>> photoFutures = capturedPhotoPaths
        .mapIndexed((index, path) =>
            ref.read(photoServiceProvider).uploadPhoto(path).then((photo) {
              if (index == preferredPhotoIndex) {
                preferredPhotoId = photo.id;
              }

              return photo;
            }))
        .toList();

    final uploadedPhotos = await Future.wait(photoFutures);

    final report = await ref
        .read(inspectionServiceProvider)
        .createReport(
            currentState[1]!.id!,
            pointId,
            uploadedPhotos.map((photo) => photo.id!).toList(),
            preferredPhotoId,
            metadata)
        .then((report) => report.copyWith(photos: uploadedPhotos));

    final currentActiveInspection = currentState[1]!.copyWith(reports: [
      ...currentState[1]!.reports,
      report,
    ]);
    state = AsyncData([currentState[0], currentActiveInspection]);
  }

  InspectionPointReport? findPreviousReportFromPoint(int pointId) {
    final previousInspection = state.value?[0];

    return previousInspection?.reports
        .firstWhereOrNull((report) => report.inspectionPointId == pointId);
  }

  InspectionPointReport? findActiveReportFromPoint(int pointId) {
    final activeInspection = state.value?[1];

    return activeInspection?.reports
        .firstWhereOrNull((report) => report.inspectionPointId == pointId);
  }
}

@riverpod
int numberOfCreatedReports(NumberOfCreatedReportsRef ref, int bridgeId) {
  final activeInspection =
      ref.watch(bridgeInspectionProvider(bridgeId)).value?[1];

  return activeInspection?.reports.length ?? 0;
}

@riverpod
bool hasActiveInspection(HasActiveInspectionRef ref, int bridgeId) {
  final activeInspection =
      ref.watch(bridgeInspectionProvider(bridgeId)).value?[1];

  return activeInspection != null;
}
