import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  admin,
  broadcaster,
  viewer,
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required UserRole role,
    required String displayName,
    String? deviceId,
    String? pairedDeviceId,
    @Default(false) bool isLoggedIn,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
