// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
part 'version.freezed.dart';
part 'version.g.dart';

@freezed
class VersionByEnvironment with _$VersionByEnvironment {
  factory VersionByEnvironment({
    Version? dev,
    Version? stg,
  }) = _VersionByEnvironment;

  factory VersionByEnvironment.fromJson(Map<String, dynamic> json) =>
      _$VersionByEnvironmentFromJson(json);
}

@freezed
class Version with _$Version {
  factory Version({
    @JsonKey(name: 'download_url') required String downloadUrl,
    @JsonKey(name: 'built_at') required DateTime builtAt,
    required String version,
  }) = _Version;

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);
}
