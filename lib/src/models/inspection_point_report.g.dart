// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionPointReportImpl _$$InspectionPointReportImplFromJson(
        Map<String, dynamic> json) =>
    _$InspectionPointReportImpl(
      id: (json['id'] as num?)?.toInt(),
      inspectionPointId: (json['inspection_point_id'] as num).toInt(),
      inspectionId: (json['inspection_id'] as num).toInt(),
      preferredPhotoId: (json['preferred_photo_id'] as num?)?.toInt(),
      isSkipped: json['is_skipped'] as bool?,
      metadata: json['meta_data'],
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
      'inspection_id': instance.inspectionId,
      'preferred_photo_id': instance.preferredPhotoId,
      'is_skipped': instance.isSkipped,
      'meta_data': instance.metadata,
      'date': instance.date?.toIso8601String(),
      'photos': instance.photos,
    };
