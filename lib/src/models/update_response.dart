// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'update_response.freezed.dart';
part 'update_response.g.dart';

@freezed
class UpdateResponse with _$UpdateResponse {
  factory UpdateResponse({
    EnvironmentFile? dev,
    EnvironmentFile? stg,
  }) = _UpdateResponse;

  factory UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateResponseFromJson(json);
}

@freezed
class EnvironmentFile with _$EnvironmentFile {
  factory EnvironmentFile({
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'date_from_filename') required String dateFromFileName,
    @JsonKey(name: 'version') required String version,
  }) = _EnvironmentFile;

  factory EnvironmentFile.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFileFromJson(json);
}