// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionPointReportImpl _$$InspectionPointReportImplFromJson(
        Map<String, dynamic> json) =>
    _$InspectionPointReportImpl(
      id: (json['id'] as num?)?.toInt(),
      status: $enumDecodeNullable(
              _$InspectionPointReportStatusEnumMap, json['status']) ??
          InspectionPointReportStatus.finished,
      inspectionPointId: (json['inspection_point_id'] as num).toInt(),
      inspectionId: (json['inspection_id'] as num).toInt(),
      metadata: json['meta_data'],
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => InspectionPointReportPhoto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InspectionPointReportImplToJson(
        _$InspectionPointReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$InspectionPointReportStatusEnumMap[instance.status]!,
      'inspection_point_id': instance.inspectionPointId,
      'inspection_id': instance.inspectionId,
      'meta_data': instance.metadata,
      'date': instance.date?.toIso8601String(),
      'photos': instance.photos,
    };

const _$InspectionPointReportStatusEnumMap = {
  InspectionPointReportStatus.finished: 'FINISHED',
  InspectionPointReportStatus.skipped: 'SKIPPED',
  InspectionPointReportStatus.pending: 'PENDING',
};
