import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/diagrams.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'damage_inspection.provider.g.dart';

class DamageInspectionState {
  final int bridgeId;
  final List<InspectionPoint> points;
  final List<Diagram> diagrams;
  final List<InspectionPointReport> reports;

  DamageInspectionState({
    required this.bridgeId,
    required this.diagrams,
    required this.points,
    required this.reports,
  });

  List<String> get sortedSpanNumbers {
    final sortedKeys = diagramsBySpanNumbers.keys.toList();
    sortedKeys.sort((a, b) {
      if (a.isEmpty) return 1;
      if (b.isEmpty) return -1;
      return a.compareTo(b);
    });
    return sortedKeys;
  }

  Map<String, Set<Diagram>> get diagramsBySpanNumbers {
    final diagramSets = <String, Set<Diagram>>{};

    for (final diagram in diagrams) {
      if (pointsByDiagramIds.containsKey(diagram.id)) {
        for (final point in pointsByDiagramIds[diagram.id]!) {
          diagramSets
              .putIfAbsent(point.spanNumber ?? '', () => {})
              .add(diagram);
        }
      } else {
        diagramSets.putIfAbsent('', () => {}).add(diagram);
      }
    }

    return diagramSets;
  }

  List<InspectionPoint> get pointsWithoutDiagram {
    return points.where((point) => point.diagram == null).toList();
  }

  Map<int, List<InspectionPoint>> get pointsByDiagramIds {
    final pointsByDiagramIds = <int, List<InspectionPoint>>{};
    for (final point in points) {
      if (point.diagram != null) {
        pointsByDiagramIds.putIfAbsent(point.diagram!.id!, () => []).add(point);
      }
    }

    return pointsByDiagramIds;
  }

  Map<int, int> get finishCountByDiagramIds {
    final finishCountByDiagramIds = <int, int>{};

    for (final diagram in diagrams) {
      finishCountByDiagramIds[diagram.id!] = 0;

      if (pointsByDiagramIds.containsKey(diagram.id)) {
        for (final point in pointsByDiagramIds[diagram.id]!) {
          if (reports.any((report) =>
              report.inspectionPointId == point.id &&
              [
                InspectionPointReportStatus.finished,
                InspectionPointReportStatus.skipped
              ].contains(report.status))) {
            finishCountByDiagramIds[diagram.id!] =
                (finishCountByDiagramIds[diagram.id!] ?? 0) + 1;
          }
        }
      }
    }

    return finishCountByDiagramIds;
  }

  Map<int, InspectionPointReportStatus> get statusByPointIds {
    final statusByPointIds = <int, InspectionPointReportStatus>{};

    for (final report in reports) {
      statusByPointIds[report.inspectionPointId] = report.status;
    }

    return statusByPointIds;
  }
}

@riverpod
class DamageInspection extends _$DamageInspection {
  @override
  FutureOr<DamageInspectionState> build(int bridgeId) async {
    final diagrams = await ref.watch(diagramsProvider(bridgeId).future);
    final damagePoints =
        await ref.watch(damageInspectionPointsProvider(bridgeId).future);
    final inspection =
        await ref.watch(bridgeInspectionProvider(bridgeId).future);

    final pointIds = damagePoints.map((point) => point.id).toList();

    return DamageInspectionState(
        bridgeId: bridgeId,
        diagrams: diagrams,
        points: damagePoints,
        reports: inspection[1]
                ?.reports
                .where((report) => pointIds.contains(report.inspectionPointId))
                .toList() ??
            []);
  }
}
