// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionPointReportImpl _$$InspectionPointReportImplFromJson(
        Map<String, dynamic> json) =>
    _$InspectionPointReportImpl(
      id: json['id'] as int?,
      inspectionPointId: json['inspection_point_id'] as int,
      preferredPhotoId: json['preferred_photo_id'] as int?,
      isSkipped: json['is_skipped'] as bool?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InspectionPointReportImplToJson(
        _$InspectionPointReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspection_point_id': instance.inspectionPointId,
      'preferred_photo_id': instance.preferredPhotoId,
      'is_skipped': instance.isSkipped,
      'date': instance.date?.toIso8601String(),
      'photos': instance.photos,
    };
