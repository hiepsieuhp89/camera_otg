// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_expansion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextExpansion _$TextExpansionFromJson(Map<String, dynamic> json) =>
    TextExpansion(
      id: (json['id'] as num).toInt(),
      abbreviation: json['abbreviation'] as String,
      expandedText: json['expanded_text'] as String,
    );

Map<String, dynamic> _$TextExpansionToJson(TextExpansion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'abbreviation': instance.abbreviation,
      'expanded_text': instance.expandedText,
    };
