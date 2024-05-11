// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/photo.dart';

part 'inspection_point_report.freezed.dart';
part 'inspection_point_report.g.dart';

@freezed
class InspectionPointReport with _$InspectionPointReport {
  factory InspectionPointReport({
    int? id,
    @JsonKey(name: 'inspection_point_id') required int inspectionPointId,
    @JsonKey(name: 'inspection_id') required int inspectionId,
    @JsonKey(name: 'preferred_photo_id') int? preferredPhotoId,
    @JsonKey(name: 'is_skipped') bool? isSkipped,
    @JsonKey(name: 'meta_data') dynamic metadata,
    DateTime? date,
    @Default([]) List<Photo> photos,
  }) = _InspectionPointReport;

  factory InspectionPointReport.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointReportFromJson(json);
}
