// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_point_report_photo.freezed.dart';
part 'inspection_point_report_photo.g.dart';

@freezed
class InspectionPointReportPhoto with _$InspectionPointReportPhoto {
  factory InspectionPointReportPhoto(
      {String? localPath,
      @JsonKey(name: 'photo_link') String? url,
      @JsonKey(name: 'photo_id') int? photoId,
      @JsonKey(name: 'photo_sequence_number') int? sequenceNumber,
      @JsonKey(name: 'report_id') int? reportId}) = _InspectionPointReportPhoto;

  factory InspectionPointReportPhoto.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointReportPhotoFromJson(json);
}
