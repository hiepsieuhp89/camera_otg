// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyoryo/src/models/photo.dart';
part 'diagram.freezed.dart';
part 'diagram.g.dart';

@freezed
class Diagram with _$Diagram {
  factory Diagram(
      {int? id,
      @JsonKey(name: 'bridge_id') required int bridgeId,
      @JsonKey(name: 'photo_id') required int photoId,
      Photo? photo}) = _Diagram;

  factory Diagram.fromJson(Map<String, dynamic> json) =>
      _$DiagramFromJson(json);
}
