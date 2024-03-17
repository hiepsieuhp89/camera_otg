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
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$InspectionPointReportImplToJson(
        _$InspectionPointReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inspection_point_id': instance.inspectionPointId,
      'date': instance.date?.toIso8601String(),
    };
