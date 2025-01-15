// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/diagram.dart';
part 'inspection_point.freezed.dart';
part 'inspection_point.g.dart';

enum InspectionPointType {
  @JsonValue('PRESENT_CONDITION')
  presentCondition,
  @JsonValue('DAMAGE')
  damage
}

@freezed
class InspectionPoint with _$InspectionPoint {
  factory InspectionPoint(
      {int? id,
      required InspectionPointType type,
      Diagram? diagram,
      @JsonKey(name: 'bridge_id') required int bridgeId,
      @JsonKey(name: 'diagram_url') String? diagramUrl,
      @JsonKey(name: 'diagram_id') int? diagramId,
      @JsonKey(name: 'diagram_marking_x') int? diagramMarkingX,
      @JsonKey(name: 'diagram_marking_y') int? diagramMarkingY,
      @JsonKey(name: 'photo_ref_number') int? photoRefNumber,
      @JsonKey(name: 'span_name') String? spanName,
      @JsonKey(name: 'span_number') String? spanNumber,
      @JsonKey(name: 'element_number') String? elementNumber,
      @JsonKey(name: 'diagram_marked_photo_link')
      String? diagramMarkedPhotoLink,
      @JsonKey(name: 'last_inspection_date')
      DateTime? lastInspectionDate}) = _InpsectionPoint;

  factory InspectionPoint.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointFromJson(json);
}
