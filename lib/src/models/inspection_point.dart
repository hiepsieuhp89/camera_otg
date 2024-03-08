// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'inspection_point.freezed.dart';
part 'inspection_point.g.dart';

enum InspectionPointType {
  @JsonValue('PRESENT_CONDITION')
  presentCondition,
  @JsonValue('DAMAGE')
  damage,
}

@freezed
class InspectionPoint with _$InspectionPoint {
  factory InspectionPoint(
      {int? id,
      required InspectionPointType type,
      String? name,
      @JsonKey(name: 'bridge_id') int? bridgeId,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'diagram_url') String? diagramUrl,
      @JsonKey(name: 'last_inspection_date')
      DateTime? lastInspectionDate}) = _InpsectionPoint;

  factory InspectionPoint.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointFromJson(json);
}
