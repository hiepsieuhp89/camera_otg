// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bridge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BridgeImpl _$$BridgeImplFromJson(Map<String, dynamic> json) => _$BridgeImpl(
      id: (json['id'] as num).toInt(),
      condition: json['condition'] as String?,
      bridgeNo: json['bridge_no'] as String,
      managementNo: json['management_no'] as String,
      nameKana: json['name_kana'] as String?,
      photoLink: json['photo_link'] as String,
      nameKanji: json['name_kanji'] as String,
      lastInspectionDate: json['last_inspection_date'] == null
          ? null
          : DateTime.parse(json['last_inspection_date'] as String),
    );

Map<String, dynamic> _$$BridgeImplToJson(_$BridgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'condition': instance.condition,
      'bridge_no': instance.bridgeNo,
      'management_no': instance.managementNo,
      'name_kana': instance.nameKana,
      'photo_link': instance.photoLink,
      'name_kanji': instance.nameKanji,
      'last_inspection_date': instance.lastInspectionDate?.toIso8601String(),
    };
