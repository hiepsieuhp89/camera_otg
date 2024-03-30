// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionImpl _$$InspectionImplFromJson(Map<String, dynamic> json) =>
    _$InspectionImpl(
      id: json['id'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      bridgeId: json['bridge_id'] as int,
      reports: (json['reports'] as List<dynamic>?)
              ?.map((e) =>
                  InspectionPointReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$InspectionImplToJson(_$InspectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'bridge_id': instance.bridgeId,
      'reports': instance.reports,
    };
