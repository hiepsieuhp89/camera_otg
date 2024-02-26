// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'bridge_element.freezed.dart';
part 'bridge_element.g.dart';

@freezed
class BridgeElement with _$BridgeElement {
  factory BridgeElement(
      {String? id,
      String? name,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'blueprint_url') String? blueprintUrl,
      @JsonKey(name: 'last_inspection_date')
      DateTime? lastInspectionDate}) = _BridgeElement;

  factory BridgeElement.fromJson(Map<String, dynamic> json) =>
      _$BridgeElementFromJson(json);
}
