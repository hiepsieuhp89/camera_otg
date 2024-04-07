// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InpsectionPointImpl _$$InpsectionPointImplFromJson(
        Map<String, dynamic> json) =>
    _$InpsectionPointImpl(
      id: json['id'] as int?,
      type: $enumDecode(_$InspectionPointTypeEnumMap, json['type']),
      name: json['name'] as String?,
      bridgeId: json['bridge_id'] as int?,
      photoUrl: json['photo_url'] as String?,
      diagramUrl: json['diagram_url'] as String?,
      diagramId: json['diagram_id'] as int?,
      diagramMarkingX: json['diagram_marking_x'] as int?,
      diagramMarkingY: json['diagram_marking_y'] as int?,
      photoRefNumber: json['photo_ref_number'] as int?,
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
      'bridge_id': instance.bridgeId,
      'photo_url': instance.photoUrl,
      'diagram_url': instance.diagramUrl,
      'diagram_id': instance.diagramId,
      'diagram_marking_x': instance.diagramMarkingX,
      'diagram_marking_y': instance.diagramMarkingY,
      'photo_ref_number': instance.photoRefNumber,
      'diagram_marked_photo_link': instance.diagramMarkedPhotoLink,
      'last_inspection_date': instance.lastInspectionDate?.toIso8601String(),
    };

const _$InspectionPointTypeEnumMap = {
  InspectionPointType.presentCondition: 'PRESENT_CONDITION',
  InspectionPointType.damage: 'DAMAGE',
};
