// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'municipality.freezed.dart';
part 'municipality.g.dart';

@freezed
class Municipality with _$Municipality {
  factory Municipality({
    @JsonKey(name: 'name_kanji') required String nameKanji,
    required String code,
    String? id,
    @JsonKey(name: 'name_romaji') String? nameRomaji,
    @JsonKey(name: 'name_kana') String? nameKana,
    @JsonKey(name: 'prefecture_kanji') String? prefectureKanji,
    @JsonKey(name: 'prefecture_kana') String? prefectureKana,
    @JsonKey(name: 'prefecture_romaji') String? prefectureRomaji,
    @JsonKey(name: 'lat') num? latitude,
    @JsonKey(name: 'lon') num? longitude,
  }) = _Municipality;

  factory Municipality.fromJson(Map<String, dynamic> json) =>
      _$MunicipalityFromJson(json);
}
