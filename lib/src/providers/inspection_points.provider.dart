import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:kyoryo/src/services/photo.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_points.provider.g.dart';

@riverpod
class InspectionPoints extends _$InspectionPoints {
  @override
  Future<List<InspectionPoint>> build(int bridgeId) async {
    return ref.watch(bridgeServiceProvider).fetchInspectionPoints(bridgeId);
  }

  Future<InspectionPoint> createInspectionPoint(
      InspectionPoint point, String diagramPath) async {
    final diagramPhoto =
        await ref.watch(photoServiceProvider).uploadPhoto(diagramPath);

    final inspectionPoint = await ref
        .watch(bridgeServiceProvider)
        .createInspectionPoint(point.copyWith(diagramId: diagramPhoto.id));

    final previousState = await future;

    state = AsyncData([inspectionPoint, ...previousState]);

    return inspectionPoint;
  }
}

@riverpod
class CurrentInspectionPointType extends _$CurrentInspectionPointType {
  @override
  InspectionPointType? build() {
    return null;
  }

  void set(InspectionPointType? type) {
    state = type;
  }
}

@riverpod
Future<List<InspectionPoint>> filteredInspectionPoints(
    FilteredInspectionPointsRef ref, int bridgeId) {
  final selectedType = ref.watch(currentInspectionPointTypeProvider);
  final data = ref.watch(inspectionPointsProvider(bridgeId).selectAsync(
      (points) => points
          .where((point) => selectedType == null || selectedType == point.type)
          .toList()));

  return data;
}
