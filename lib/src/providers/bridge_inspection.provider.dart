import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_inspection.provider.g.dart';

@riverpod
class BridgeInspection extends _$BridgeInspection {
  @override
  Future<List<Inspection?>> build(int bridgeId) async {
    final inspections =
        await ref.read(apiServiceProvider).fetchInspections(bridgeId);

    Inspection? activeInspection;
    Inspection? importedInspection;

    for (var inspection in inspections) {
      if (!inspection.isImported) {
        activeInspection = inspection;
        break;
      }
    }

    for (var inspection in inspections.reversed) {
      if (inspection.isImported) {
        importedInspection = inspection;
        break;
      }
    }

    List<Inspection?> inspectionsToReturn = [];

    if (importedInspection != null) {
      final inspection = await ref
          .read(apiServiceProvider)
          .fetchInspection(importedInspection.id!);

      inspectionsToReturn.add(inspection);
    } else {
      inspectionsToReturn.add(null);
    }

    if (activeInspection != null) {
      final inspection = await ref
          .read(apiServiceProvider)
          .fetchInspection(activeInspection.id!);

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
      String? preferredPhotoPath,
      InspectionPointReportStatus status =
          InspectionPointReportStatus.finished}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    List<InspectionPointReportPhoto> reportPhotos = [];

    for (int i = 0; i < capturedPhotoPaths.length; i++) {
      String path = capturedPhotoPaths[i];
      Photo photo = await ref.read(apiServiceProvider).uploadPhoto(path);

      reportPhotos.add(InspectionPointReportPhoto(
          photoId: photo.id!,
          url: path,
          sequenceNumber: path == preferredPhotoPath ? 1 : null));
    }

    final report = await ref.read(apiServiceProvider).createReport(
          report: InspectionPointReport(
              photos: reportPhotos,
              inspectionPointId: pointId,
              inspectionId: currentState[1]!.id!,
              metadata: metadata,
              status: status),
        );

    final currentActiveInspection = currentState[1]!.copyWith(reports: [
      ...currentState[1]!.reports,
      report,
    ]);
    state = AsyncData([currentState[0], currentActiveInspection]);
  }

  Future<void> updateReport(
      {required InspectionPointReport report,
      required List<String> capturedPhotoPaths,
      required List<InspectionPointReportPhoto> uploadedPhotos,
      String? preferredPhotoPath}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    if (report.inspectionId != currentState[1]!.id) {
      debugPrint('Report does not belong to active inspection');
      return;
    }

    List<InspectionPointReportPhoto> newPhotos = [];

    for (int i = 0; i < capturedPhotoPaths.length; i++) {
      String path = capturedPhotoPaths[i];
      Photo photo = await ref.read(apiServiceProvider).uploadPhoto(path);
      newPhotos.add(InspectionPointReportPhoto(
          url: photo.photoLink,
          photoId: photo.id!,
          sequenceNumber: preferredPhotoPath == path ? 1 : null));
    }

    for (int i = 0; i < uploadedPhotos.length; i++) {
      if (uploadedPhotos[i].url == preferredPhotoPath) {
        uploadedPhotos[i] = uploadedPhotos[i].copyWith(sequenceNumber: 1);
      } else {
        uploadedPhotos[i] = uploadedPhotos[i].copyWith(sequenceNumber: null);
      }
    }

    final updatedReport =
        await ref.read(apiServiceProvider).updateReport(report.copyWith(
              photos: [...uploadedPhotos, ...newPhotos],
            ));

    final currentActiveInspection = currentState[1]!.copyWith(
      reports: [
        ...currentState[1]!.reports.where((r) => r.id != updatedReport.id),
        updatedReport,
      ],
    );

    state = AsyncData([currentState[0], currentActiveInspection]);
  }

  Future<void> setActiveInspectionFinished(bool isFinished) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    await ref
        .read(apiServiceProvider)
        .finishInspection(currentState[1]!.id!, isFinished);

    state = AsyncData(
        [currentState[0], currentState[1]!.copyWith(isFinished: isFinished)]);
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

  return activeInspection?.reports
          .where(
              (report) => report.status == InspectionPointReportStatus.finished)
          .length ??
      0;
}

@riverpod
bool isInspectionInProgress(IsInspectionInProgressRef ref, int bridgeId) {
  Inspection? activeInspection =
      ref.watch(bridgeInspectionProvider(bridgeId)).value?[1];

  return activeInspection != null ? !activeInspection.isFinished : false;
}
