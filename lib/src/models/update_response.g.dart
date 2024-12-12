// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateResponseImpl _$$UpdateResponseImplFromJson(Map<String, dynamic> json) =>
    _$UpdateResponseImpl(
      dev: json['dev'] == null
          ? null
          : EnvironmentFile.fromJson(json['dev'] as Map<String, dynamic>),
      stg: json['stg'] == null
          ? null
          : EnvironmentFile.fromJson(json['stg'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UpdateResponseImplToJson(
        _$UpdateResponseImpl instance) =>
    <String, dynamic>{
      'dev': instance.dev,
      'stg': instance.stg,
    };

_$EnvironmentFileImpl _$$EnvironmentFileImplFromJson(
        Map<String, dynamic> json) =>
    _$EnvironmentFileImpl(
      fileName: json['file_name'] as String,
      dateFromFileName: json['date_from_filename'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$$EnvironmentFileImplToJson(
        _$EnvironmentFileImpl instance) =>
    <String, dynamic>{
      'file_name': instance.fileName,
      'date_from_filename': instance.dateFromFileName,
      'version': instance.version,
    };
