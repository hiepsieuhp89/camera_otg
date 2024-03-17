// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'municipality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MunicipalityImpl _$$MunicipalityImplFromJson(Map<String, dynamic> json) =>
    _$MunicipalityImpl(
      nameKanji: json['name_kanji'] as String,
      code: json['code'] as String,
      id: json['id'] as String?,
      nameRomaji: json['name_romaji'] as String?,
      nameKana: json['name_kana'] as String?,
      prefectureKanji: json['prefecture_kanji'] as String?,
      prefectureKana: json['prefecture_kana'] as String?,
      prefectureRomaji: json['prefecture_romaji'] as String?,
      latitude: json['lat'] as num?,
      longitude: json['lon'] as num?,
    );

Map<String, dynamic> _$$MunicipalityImplToJson(_$MunicipalityImpl instance) =>
    <String, dynamic>{
      'name_kanji': instance.nameKanji,
      'code': instance.code,
      'id': instance.id,
      'name_romaji': instance.nameRomaji,
      'name_kana': instance.nameKana,
      'prefecture_kanji': instance.prefectureKanji,
      'prefecture_kana': instance.prefectureKana,
      'prefecture_romaji': instance.prefectureRomaji,
      'lat': instance.latitude,
      'lon': instance.longitude,
    };
