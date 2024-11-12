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

  Future<void> createReport({required InspectionPointReport report}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    List<InspectionPointReportPhoto> reportPhotos = [];

    for (int i = 0; i < report.photos.length; i++) {
      if (report.photos[i].photoId == null &&
          report.photos[i].localPath != null) {
        Photo photo = await ref
            .read(apiServiceProvider)
            .uploadPhoto(report.photos[i].localPath!);

        reportPhotos.add(report.photos[i].copyWith(
          photoId: photo.id,
          url: photo.photoLink,
        ));
      } else {
        reportPhotos.add(report.photos[i]);
      }
    }

    final created = await ref.read(apiServiceProvider).createReport(
          report: report.copyWith(
              photos: reportPhotos, inspectionId: currentState[1]!.id!),
        );

    final currentActiveInspection = currentState[1]!.copyWith(reports: [
      ...currentState[1]!.reports,
      created,
    ]);
    state = AsyncData([currentState[0], currentActiveInspection]);
  }

  Future<void> updateReport({required InspectionPointReport report}) async {
    final currentState = await future;

    if (currentState[1] == null) {
      throw Exception('No active inspection found');
    }

    if (report.inspectionId != currentState[1]!.id) {
      debugPrint('Report does not belong to active inspection');
      return;
    }

    List<InspectionPointReportPhoto> photos = List.from(report.photos);

    for (int i = 0; i < photos.length; i++) {
      if (photos[i].photoId == null && photos[i].localPath != null) {
        Photo photo = await ref
            .read(apiServiceProvider)
            .uploadPhoto(photos[i].localPath!);

        photos[i] = photos[i].copyWith(photoId: photo.id, url: photo.photoLink);
      }
    }

    final updatedReport =
        await ref.read(apiServiceProvider).updateReport(report.copyWith(
              photos: photos,
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

  int count = 0;

  for (var report in activeInspection?.reports ?? []) {
    if (report.status == InspectionPointReportStatus.finished ||
        report.status == InspectionPointReportStatus.skipped) {
      count++;
    }
  }

  return count;
}

@riverpod
bool isInspectionInProgress(IsInspectionInProgressRef ref, int bridgeId) {
  Inspection? activeInspection =
      ref.watch(bridgeInspectionProvider(bridgeId)).value?[1];

  return activeInspection != null ? !activeInspection.isFinished : false;
}

@riverpod
int numberOfPendingReports(NumberOfPendingReportsRef ref, int bridgeId) {
  final activeInspection =
      ref.watch(bridgeInspectionProvider(bridgeId)).value?[1];

  int pendingCount = 0;

  for (var report in activeInspection?.reports ?? []) {
    if (report.status == InspectionPointReportStatus.pending) {
      pendingCount++;
    }
  }

  return pendingCount;
}
