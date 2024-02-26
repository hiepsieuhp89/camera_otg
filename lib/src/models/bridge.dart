// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'bridge.freezed.dart';
part 'bridge.g.dart';

@freezed
class Bridge with _$Bridge {
  factory Bridge({
    String? id,
    String? condition,
    @JsonKey(name: 'bridge_no') required String bridgeNo,
    @JsonKey(name: 'management_no') required String managementNo,
    @JsonKey(name: 'name_kana') String? nameKana,
    @JsonKey(name: 'name_kanji') required String nameKanji,
    @JsonKey(name: 'last_inspection_date') DateTime? lastInspectionDate,
  }) = _Bridge;

  factory Bridge.fromJson(Map<String, dynamic> json) => _$BridgeFromJson(json);
}
