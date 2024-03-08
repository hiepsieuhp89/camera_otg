// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'contractor.freezed.dart';
part 'contractor.g.dart';

@freezed
class Contractor with _$Contractor {
  factory Contractor({
    required int id,
    @JsonKey(name: 'name_jp') required String nameJp,
    @JsonKey(name: 'name_en') required String nameEn,
  }) = _Contractor;

  factory Contractor.fromJson(Map<String, dynamic> json) =>
      _$ContractorFromJson(json);
}
