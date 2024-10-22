// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point_report_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionPointReportPhotoImpl _$$InspectionPointReportPhotoImplFromJson(
        Map<String, dynamic> json) =>
    _$InspectionPointReportPhotoImpl(
      url: json['photo_link'] as String,
      photoId: (json['photo_id'] as num).toInt(),
      sequenceNumber: (json['photo_sequence_number'] as num?)?.toInt(),
      reportId: (json['report_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$InspectionPointReportPhotoImplToJson(
        _$InspectionPointReportPhotoImpl instance) =>
    <String, dynamic>{
      'photo_link': instance.url,
      'photo_id': instance.photoId,
      'photo_sequence_number': instance.sequenceNumber,
      'report_id': instance.reportId,
    };
