// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_point_report_photo.freezed.dart';
part 'inspection_point_report_photo.g.dart';

@freezed
class InspectionPointReportPhoto with _$InspectionPointReportPhoto {
  factory InspectionPointReportPhoto(
      {@JsonKey(name: 'photo_link') required String url,
      @JsonKey(name: 'photo_id') required int photoId,
      @JsonKey(name: 'photo_sequence_number') int? sequenceNumber,
      @JsonKey(name: 'report_id') int? reportId}) = _InspectionPointReportPhoto;

  factory InspectionPointReportPhoto.fromJson(Map<String, dynamic> json) =>
      _$InspectionPointReportPhotoFromJson(json);
}
