// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionImpl _$$InspectionImplFromJson(Map<String, dynamic> json) =>
    _$InspectionImpl(
      id: (json['id'] as num?)?.toInt(),
      isFinished: json['is_finished'] as bool,
      isImported: json['is_imported'] as bool,
      bridgeId: (json['bridge_id'] as num).toInt(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      reports: (json['reports'] as List<dynamic>?)
              ?.map((e) =>
                  InspectionPointReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InspectionImplToJson(_$InspectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_finished': instance.isFinished,
      'is_imported': instance.isImported,
      'bridge_id': instance.bridgeId,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'reports': instance.reports,
    };
