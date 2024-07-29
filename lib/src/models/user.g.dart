// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      name: json['name'] as String,
      email: json['email'] as String,
      picture: json['picture'] as String,
      givenName: json['given_name'] as String?,
      familyName: json['family_name'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'picture': instance.picture,
      'given_name': instance.givenName,
      'family_name': instance.familyName,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
