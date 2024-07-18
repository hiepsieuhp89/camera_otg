import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/inspection_point_filters.provider.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'inspection_points.provider.g.dart';

@riverpod
class InspectionPoints extends _$InspectionPoints {
  @override
  Future<List<InspectionPoint>> build(int bridgeId) async {
    return ref.watch(bridgeServiceProvider).fetchInspectionPoints(bridgeId);
  }

  Future<InspectionPoint> createInspectionPoint(InspectionPoint point) async {
    final inspectionPoint =
        await ref.watch(bridgeServiceProvider).createInspectionPoint(point);

    final previousState = await future;

    state = AsyncData([inspectionPoint, ...previousState]);

    return inspectionPoint;
  }
}

@riverpod
Future<List<InspectionPoint>> filteredInspectionPoints(
    FilteredInspectionPointsRef ref, int bridgeId) async {
  InspectionPointFilters filters =
      ref.watch(bridgeInspectionPointFiltersProvider(bridgeId));
  final activeInspection =
      (await ref.watch(bridgeInspectionProvider(bridgeId).future))[1];

  final data = ref.watch(inspectionPointsProvider(bridgeId)
      .selectAsync((points) => points.where((point) {
            if (filters.typeFilter != null &&
                point.type != filters.typeFilter) {
              return false;
            }

            if (filters.nameFilters.isNotEmpty &&
                !filters.nameFilters.contains(point.name ?? '')) {
              return false;
            }

            InspectionPointReport? report = activeInspection?.reports
                .firstWhereOrNull(
                    (report) => report.inspectionPointId == point.id);

            if (report == null && !filters.includeNoReport) {
              return false;
            }

            if (report != null &&
                !(filters.reportStatusFilters[report.status] ?? false)) {
              return false;
            }

            return true;
          }).toList()));

  return data;
}
