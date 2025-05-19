// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      displayName: json['displayName'] as String,
      deviceId: json['deviceId'] as String?,
      pairedDeviceId: json['pairedDeviceId'] as String?,
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'displayName': instance.displayName,
      'deviceId': instance.deviceId,
      'pairedDeviceId': instance.pairedDeviceId,
      'isLoggedIn': instance.isLoggedIn,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.broadcaster: 'broadcaster',
  UserRole.viewer: 'viewer',
};
