import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'text_expansion.g.dart';

@JsonSerializable()
class TextExpansion {
  final int id;
  final String abbreviation;
  @JsonKey(name: 'expanded_text')
  final String expandedText;

  TextExpansion({
    required this.id,
    required this.abbreviation,
    required this.expandedText,
  });

  factory TextExpansion.fromJson(Map<String, dynamic> json) =>
      _$TextExpansionFromJson(json);

  Map<String, dynamic> toJson() => _$TextExpansionToJson(this);
} 