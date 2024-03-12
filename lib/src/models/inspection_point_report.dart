// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'inspection_point_report.freezed.dart';
part 'inspection_point_report.g.dart';

@freezed
class InspectionPointReport with _$InspectionPointReport {
  factory InspectionPointReport({
    int? id,
    @JsonKey(name: 'inspection_point_id') required int inspectionPointId,
    @JsonKey(name: 'date') DateTime? date,
  }) = _InspectionPointReport;

  factory InspectionPointReport.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointReportFromJson(json);
}
