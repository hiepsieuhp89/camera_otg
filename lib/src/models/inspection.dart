// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

@freezed
class Inspection with _$Inspection {
  factory Inspection({
    int? id,
    required DateTime timestamp,
    @JsonKey(name: 'bridge_id') required int bridgeId,
    @Default([]) List<InspectionPointReport> reports,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);
}
