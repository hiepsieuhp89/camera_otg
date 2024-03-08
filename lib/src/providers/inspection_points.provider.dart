import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_points.provider.g.dart';

@riverpod
class InspectionPoints extends _$InspectionPoints {
  @override
  Future<List<InspectionPoint>> build(int bridgeId) async {
    return ref.watch(bridgeServiceProvider).fetchInspectionPoints(bridgeId);
  }
}
