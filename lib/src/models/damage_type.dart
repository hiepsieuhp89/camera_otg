// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'damage_type.freezed.dart';
part 'damage_type.g.dart';

@freezed
class DamageType with _$DamageType {
  factory DamageType({
    required int id,
    required String category,
    @JsonKey(name: 'name_jp') required String nameJp,
    @JsonKey(name: 'name_en') required String nameEn,
  }) = _DamageType;

  factory DamageType.fromJson(Map<String, dynamic> json) =>
      _$DamageTypeFromJson(json);
}
