// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagram.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiagramImpl _$$DiagramImplFromJson(Map<String, dynamic> json) =>
    _$DiagramImpl(
      id: json['id'] as int?,
      bridgeId: json['bridge_id'] as int,
      photoId: json['photo_id'] as int,
      photo: json['photo'] == null
          ? null
          : Photo.fromJson(json['photo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DiagramImplToJson(_$DiagramImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bridge_id': instance.bridgeId,
      'photo_id': instance.photoId,
      'photo': instance.photo,
    };
