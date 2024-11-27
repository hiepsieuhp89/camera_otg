import 'package:collection/collection.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagram_inspection.provider.g.dart';

class DiagramInspectionState {
  final Diagram diagram;
  final List<InspectionPoint> points;
  final List<InspectionPointReport> reports;
  final List<InspectionPointReport> previousReports;
  List<InspectionPoint> selectedPoints = [];

  DiagramInspectionState(
      {required this.diagram,
      required this.points,
      required this.reports,
      required this.previousReports,
      this.selectedPoints = const []});

  String get spanNumber {
    for (var point in points) {
      if (point.spanNumber != null && point.spanNumber!.isNotEmpty) {
        return point.spanNumber!;
      }
    }
    return '';
  }

  String get spanName {
    for (var point in points) {
      if (point.spanName != null && point.spanName!.isNotEmpty) {
        return point.spanName!;
      }
    }
    return '';
  }

  int get finishedCount {
    int count = 0;

    for (final point in points) {
      if (reports.any((report) =>
          report.inspectionPointId == point.id &&
          [
            InspectionPointReportStatus.finished,
            InspectionPointReportStatus.skipped
          ].contains(report.status))) {
        count++;
      }
    }

    return count;
  }

  bool isPointSelected(InspectionPoint point) {
    return selectedPoints.length != points.length &&
        selectedPoints.contains(point);
  }

  DiagramInspectionState copyWith({
    Diagram? diagram,
    List<InspectionPoint>? points,
    List<InspectionPointReport>? reports,
    List<InspectionPointReport>? previousReports,
    List<InspectionPoint>? selectedPoints,
  }) {
    return DiagramInspectionState(
        diagram: diagram ?? this.diagram,
        points: points ?? this.points,
        reports: reports ?? this.reports,
        previousReports: previousReports ?? this.previousReports,
        selectedPoints: selectedPoints ?? this.selectedPoints);
  }
}

@riverpod
class DiagramInspection extends _$DiagramInspection {
  @override
  FutureOr<DiagramInspectionState> build(Diagram diagram) async {
    final currentBridge = ref.watch(currentBridgeProvider);
    final inspection =
        await ref.watch(bridgeInspectionProvider(currentBridge!.id).future);

    final allPoints = await ref
        .watch(damageInspectionPointsProvider(currentBridge.id).future);
    final points =
        allPoints.where((point) => point.diagram?.id == diagram.id).toList();
    final pointIds = points.map((point) => point.id).toList();

    return DiagramInspectionState(
      diagram: diagram,
      points: points,
      selectedPoints: points,
      reports: inspection[1]
              ?.reports
              .where((report) => pointIds.contains(report.inspectionPointId))
              .toList() ??
          [],
      previousReports: inspection[0]
              ?.reports
              .where((report) => pointIds.contains(report.inspectionPointId))
              .toList() ??
          [],
    );
  }

  Future<void> setSelectedPoints(List<InspectionPoint>? points) async {
    final currentState = await future;

    if (points == null) {
      state =
          AsyncData(currentState.copyWith(selectedPoints: currentState.points));
    } else {
      state = AsyncData(currentState.copyWith(selectedPoints: points));
    }
  }

  InspectionPointReport? findPreviousReportFromPoint(int pointId) {
    return state.value?.previousReports
        .firstWhereOrNull((report) => report.inspectionPointId == pointId);
  }

  InspectionPointReport? findActiveReportFromPoint(int pointId) {
    return state.value?.reports
        .firstWhereOrNull((report) => report.inspectionPointId == pointId);
  }
}
