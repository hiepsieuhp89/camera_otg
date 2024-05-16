// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';

part 'inspection.freezed.dart';
part 'inspection.g.dart';

@freezed
class Inspection with _$Inspection {
  factory Inspection({
    int? id,
    @JsonKey(name: 'is_finished') required bool isFinished,
    @JsonKey(name: 'is_imported') required bool isImported,
    @JsonKey(name: 'bridge_id') required int bridgeId,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @Default([]) List<InspectionPointReport> reports,
  }) = _Inspection;

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);
}
