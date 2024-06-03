// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InpsectionPointImpl _$$InpsectionPointImplFromJson(
        Map<String, dynamic> json) =>
    _$InpsectionPointImpl(
      id: (json['id'] as num?)?.toInt(),
      type: $enumDecode(_$InspectionPointTypeEnumMap, json['type']),
      name: json['name'] as String?,
      diagram: json['diagram'] == null
          ? null
          : Diagram.fromJson(json['diagram'] as Map<String, dynamic>),
      bridgeId: (json['bridge_id'] as num?)?.toInt(),
      diagramUrl: json['diagram_url'] as String?,
      diagramId: (json['diagram_id'] as num?)?.toInt(),
      diagramMarkingX: (json['diagram_marking_x'] as num?)?.toInt(),
      diagramMarkingY: (json['diagram_marking_y'] as num?)?.toInt(),
      photoRefNumber: (json['photo_ref_number'] as num?)?.toInt(),
      spanName: json['span_name'] as String?,
      spanNumber: json['span_number'] as String?,
      elementNumber: json['element_number'] as String?,
      diagramMarkedPhotoLink: json['diagram_marked_photo_link'] as String?,
      lastInspectionDate: json['last_inspection_date'] == null
          ? null
          : DateTime.parse(json['last_inspection_date'] as String),
    );

Map<String, dynamic> _$$InpsectionPointImplToJson(
        _$InpsectionPointImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$InspectionPointTypeEnumMap[instance.type]!,
      'name': instance.name,
      'diagram': instance.diagram,
      'bridge_id': instance.bridgeId,
      'diagram_url': instance.diagramUrl,
      'diagram_id': instance.diagramId,
      'diagram_marking_x': instance.diagramMarkingX,
      'diagram_marking_y': instance.diagramMarkingY,
      'photo_ref_number': instance.photoRefNumber,
      'span_name': instance.spanName,
      'span_number': instance.spanNumber,
      'element_number': instance.elementNumber,
      'diagram_marked_photo_link': instance.diagramMarkedPhotoLink,
      'last_inspection_date': instance.lastInspectionDate?.toIso8601String(),
    };

const _$InspectionPointTypeEnumMap = {
  InspectionPointType.presentCondition: 'PRESENT_CONDITION',
  InspectionPointType.damage: 'DAMAGE',
};
