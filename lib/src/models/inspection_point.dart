// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'inspection_point.freezed.dart';
part 'inspection_point.g.dart';

@freezed
class InpsectionPoint with _$InpsectionPoint {
  factory InpsectionPoint(
      {String? id,
      String? name,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'blueprint_url') String? blueprintUrl,
      @JsonKey(name: 'last_inspection_date')
      DateTime? lastInspectionDate}) = _InpsectionPoint;

  factory InpsectionPoint.fromJson(Map<String, dynamic> json) =>
      _$InpsectionPointFromJson(json);
}
