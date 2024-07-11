import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:kyoryo/src/services/inspection.service.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/services/photo.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridge_inspection.provider.g.dart';

@riverpod
class BridgeInspection extends _$BridgeInspection {
  @override
  Future<List<Inspection?>> build(int bridgeId) async {
    final inspections =
        await ref.read(bridgeServiceProvider).fetchInspections(bridgeId);

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
          .read(inspectionServiceProvider)
          .fetchInspection(importedInspection.id!);

      inspectionsToReturn.add(inspection);
    } else {
      inspectionsToReturn.add(null);
    }

    if (activeInspection != null) {
      final inspection = await ref
          .read(inspectionServiceProvider)
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

    List<Photo> uploadedPhotos = [];
    int? preferredPhotoId;

    for (int i = 0; i < capturedPhotoPaths.length; i++) {
      String path = capturedPhotoPaths[i];
      Photo photo = await ref.read(photoServiceProvider).uploadPhoto(path);
      if (path == preferredPhotoPath) {
        preferredPhotoId = photo.id;
      }
      uploadedPhotos.add(photo);
    }

    final report = await ref
        .read(inspectionServiceProvider)
        .createReport(
            report: InspectionPointReport(
                inspectionPointId: pointId,
                inspectionId: currentState[1]!.id!,
                preferredPhotoId: preferredPhotoId,
                metadata: metadata,
                status: status),
            photoIds: uploadedPhotos.map((photo) => photo.id!).toList())
        .then((report) => report.copyWith(photos: uploadedPhotos));

    final currentActiveInspection = currentState[1]!.copyWith(reports: [
      ...currentState[1]!.reports,
      report,
    ]);
    state = AsyncData([currentState[0], currentActiveInspection]);
  }

  Future<void> updateReport(
      {required InspectionPointReport report,
      required List<String> capturedPhotoPaths,
      required List<Photo> uploadedPhotos,
      String? preferredPhotoPath}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    if (report.inspectionId != currentState[1]!.id) {
      debugPrint('Report does not belong to active inspection');
      return;
    }

    int? preferredPhotoId;
    List<Photo> newPhotos = [];

    for (int i = 0; i < capturedPhotoPaths.length; i++) {
      String path = capturedPhotoPaths[i];
      Photo photo = await ref.read(photoServiceProvider).uploadPhoto(path);
      if (path == preferredPhotoPath) {
        preferredPhotoId = photo.id;
      }
      newPhotos.add(photo);
    }

    for (Photo photo in uploadedPhotos) {
      if (photo.photoLink == preferredPhotoPath) {
        preferredPhotoId = photo.id;
        break;
      }
    }

    final updatedReport = await ref
        .read(inspectionPointReportServiceProvider)
        .updateReport(report.copyWith(
            photos: [...uploadedPhotos, ...newPhotos],
            preferredPhotoId: preferredPhotoId));

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
        .read(inspectionServiceProvider)
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
