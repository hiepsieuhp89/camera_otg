// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DamageTypeImpl _$$DamageTypeImplFromJson(Map<String, dynamic> json) =>
    _$DamageTypeImpl(
      id: json['id'] as int,
      category: json['category'] as String,
      nameJp: json['name_jp'] as String,
      nameEn: json['name_en'] as String,
    );

Map<String, dynamic> _$$DamageTypeImplToJson(_$DamageTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'name_jp': instance.nameJp,
      'name_en': instance.nameEn,
    };
