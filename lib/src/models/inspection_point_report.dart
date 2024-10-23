// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';

part 'inspection_point_report.freezed.dart';
part 'inspection_point_report.g.dart';

enum InspectionPointReportStatus {
  @JsonValue('FINISHED')
  finished,
  @JsonValue('SKIPPED')
  skipped,
  @JsonValue('PENDING')
  pending,
}

@freezed
class InspectionPointReport with _$InspectionPointReport {
  factory InspectionPointReport({
    int? id,
    @Default(InspectionPointReportStatus.finished)
    InspectionPointReportStatus status,
    @JsonKey(name: 'inspection_point_id') required int inspectionPointId,
    @JsonKey(name: 'inspection_id') int? inspectionId,
    @JsonKey(name: 'meta_data') dynamic metadata,
    DateTime? date,
    @Default([]) List<InspectionPointReportPhoto> photos,
  }) = _InspectionPointReport;

  factory InspectionPointReport.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointReportFromJson(json);
}
