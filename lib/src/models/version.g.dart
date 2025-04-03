// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VersionByEnvironmentImpl _$$VersionByEnvironmentImplFromJson(
        Map<String, dynamic> json) =>
    _$VersionByEnvironmentImpl(
      dev: json['dev'] == null
          ? null
          : Version.fromJson(json['dev'] as Map<String, dynamic>),
      stg: json['stg'] == null
          ? null
          : Version.fromJson(json['stg'] as Map<String, dynamic>),
      prd: json['prd'] == null
          ? null
          : Version.fromJson(json['prd'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$VersionByEnvironmentImplToJson(
        _$VersionByEnvironmentImpl instance) =>
    <String, dynamic>{
      'dev': instance.dev,
      'stg': instance.stg,
      'prd': instance.prd,
    };

_$VersionImpl _$$VersionImplFromJson(Map<String, dynamic> json) =>
    _$VersionImpl(
      downloadUrl: json['download_url'] as String,
      builtAt: DateTime.parse(json['built_at'] as String),
      version: json['version'] as String,
    );

Map<String, dynamic> _$$VersionImplToJson(_$VersionImpl instance) =>
    <String, dynamic>{
      'download_url': instance.downloadUrl,
      'built_at': instance.builtAt.toIso8601String(),
      'version': instance.version,
    };
