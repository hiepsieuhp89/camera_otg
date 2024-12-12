// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdateResponse _$UpdateResponseFromJson(Map<String, dynamic> json) {
  return _UpdateResponse.fromJson(json);
}

/// @nodoc
mixin _$UpdateResponse {
  EnvironmentFile? get dev => throw _privateConstructorUsedError;
  EnvironmentFile? get stg => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateResponseCopyWith<UpdateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateResponseCopyWith<$Res> {
  factory $UpdateResponseCopyWith(
          UpdateResponse value, $Res Function(UpdateResponse) then) =
      _$UpdateResponseCopyWithImpl<$Res, UpdateResponse>;
  @useResult
  $Res call({EnvironmentFile? dev, EnvironmentFile? stg});

  $EnvironmentFileCopyWith<$Res>? get dev;
  $EnvironmentFileCopyWith<$Res>? get stg;
}

/// @nodoc
class _$UpdateResponseCopyWithImpl<$Res, $Val extends UpdateResponse>
    implements $UpdateResponseCopyWith<$Res> {
  _$UpdateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dev = freezed,
    Object? stg = freezed,
  }) {
    return _then(_value.copyWith(
      dev: freezed == dev
          ? _value.dev
          : dev // ignore: cast_nullable_to_non_nullable
              as EnvironmentFile?,
      stg: freezed == stg
          ? _value.stg
          : stg // ignore: cast_nullable_to_non_nullable
              as EnvironmentFile?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EnvironmentFileCopyWith<$Res>? get dev {
    if (_value.dev == null) {
      return null;
    }

    return $EnvironmentFileCopyWith<$Res>(_value.dev!, (value) {
      return _then(_value.copyWith(dev: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EnvironmentFileCopyWith<$Res>? get stg {
    if (_value.stg == null) {
      return null;
    }

    return $EnvironmentFileCopyWith<$Res>(_value.stg!, (value) {
      return _then(_value.copyWith(stg: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UpdateResponseImplCopyWith<$Res>
    implements $UpdateResponseCopyWith<$Res> {
  factory _$$UpdateResponseImplCopyWith(_$UpdateResponseImpl value,
          $Res Function(_$UpdateResponseImpl) then) =
      __$$UpdateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EnvironmentFile? dev, EnvironmentFile? stg});

  @override
  $EnvironmentFileCopyWith<$Res>? get dev;
  @override
  $EnvironmentFileCopyWith<$Res>? get stg;
}

/// @nodoc
class __$$UpdateResponseImplCopyWithImpl<$Res>
    extends _$UpdateResponseCopyWithImpl<$Res, _$UpdateResponseImpl>
    implements _$$UpdateResponseImplCopyWith<$Res> {
  __$$UpdateResponseImplCopyWithImpl(
      _$UpdateResponseImpl _value, $Res Function(_$UpdateResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dev = freezed,
    Object? stg = freezed,
  }) {
    return _then(_$UpdateResponseImpl(
      dev: freezed == dev
          ? _value.dev
          : dev // ignore: cast_nullable_to_non_nullable
              as EnvironmentFile?,
      stg: freezed == stg
          ? _value.stg
          : stg // ignore: cast_nullable_to_non_nullable
              as EnvironmentFile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateResponseImpl implements _UpdateResponse {
  _$UpdateResponseImpl({this.dev, this.stg});

  factory _$UpdateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateResponseImplFromJson(json);

  @override
  final EnvironmentFile? dev;
  @override
  final EnvironmentFile? stg;

  @override
  String toString() {
    return 'UpdateResponse(dev: $dev, stg: $stg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateResponseImpl &&
            (identical(other.dev, dev) || other.dev == dev) &&
            (identical(other.stg, stg) || other.stg == stg));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, dev, stg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateResponseImplCopyWith<_$UpdateResponseImpl> get copyWith =>
      __$$UpdateResponseImplCopyWithImpl<_$UpdateResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateResponseImplToJson(
      this,
    );
  }
}

abstract class _UpdateResponse implements UpdateResponse {
  factory _UpdateResponse(
      {final EnvironmentFile? dev,
      final EnvironmentFile? stg}) = _$UpdateResponseImpl;

  factory _UpdateResponse.fromJson(Map<String, dynamic> json) =
      _$UpdateResponseImpl.fromJson;

  @override
  EnvironmentFile? get dev;
  @override
  EnvironmentFile? get stg;
  @override
  @JsonKey(ignore: true)
  _$$UpdateResponseImplCopyWith<_$UpdateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EnvironmentFile _$EnvironmentFileFromJson(Map<String, dynamic> json) {
  return _EnvironmentFile.fromJson(json);
}

/// @nodoc
mixin _$EnvironmentFile {
  @JsonKey(name: 'file_name')
  String get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_from_filename')
  String get dateFromFileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'version')
  String get version => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EnvironmentFileCopyWith<EnvironmentFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnvironmentFileCopyWith<$Res> {
  factory $EnvironmentFileCopyWith(
          EnvironmentFile value, $Res Function(EnvironmentFile) then) =
      _$EnvironmentFileCopyWithImpl<$Res, EnvironmentFile>;
  @useResult
  $Res call(
      {@JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'date_from_filename') String dateFromFileName,
      @JsonKey(name: 'version') String version});
}

/// @nodoc
class _$EnvironmentFileCopyWithImpl<$Res, $Val extends EnvironmentFile>
    implements $EnvironmentFileCopyWith<$Res> {
  _$EnvironmentFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? dateFromFileName = null,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      dateFromFileName: null == dateFromFileName
          ? _value.dateFromFileName
          : dateFromFileName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EnvironmentFileImplCopyWith<$Res>
    implements $EnvironmentFileCopyWith<$Res> {
  factory _$$EnvironmentFileImplCopyWith(_$EnvironmentFileImpl value,
          $Res Function(_$EnvironmentFileImpl) then) =
      __$$EnvironmentFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'file_name') String fileName,
      @JsonKey(name: 'date_from_filename') String dateFromFileName,
      @JsonKey(name: 'version') String version});
}

/// @nodoc
class __$$EnvironmentFileImplCopyWithImpl<$Res>
    extends _$EnvironmentFileCopyWithImpl<$Res, _$EnvironmentFileImpl>
    implements _$$EnvironmentFileImplCopyWith<$Res> {
  __$$EnvironmentFileImplCopyWithImpl(
      _$EnvironmentFileImpl _value, $Res Function(_$EnvironmentFileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? dateFromFileName = null,
    Object? version = null,
  }) {
    return _then(_$EnvironmentFileImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      dateFromFileName: null == dateFromFileName
          ? _value.dateFromFileName
          : dateFromFileName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EnvironmentFileImpl implements _EnvironmentFile {
  _$EnvironmentFileImpl(
      {@JsonKey(name: 'file_name') required this.fileName,
      @JsonKey(name: 'date_from_filename') required this.dateFromFileName,
      @JsonKey(name: 'version') required this.version});

  factory _$EnvironmentFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnvironmentFileImplFromJson(json);

  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  @JsonKey(name: 'date_from_filename')
  final String dateFromFileName;
  @override
  @JsonKey(name: 'version')
  final String version;

  @override
  String toString() {
    return 'EnvironmentFile(fileName: $fileName, dateFromFileName: $dateFromFileName, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnvironmentFileImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.dateFromFileName, dateFromFileName) ||
                other.dateFromFileName == dateFromFileName) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fileName, dateFromFileName, version);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EnvironmentFileImplCopyWith<_$EnvironmentFileImpl> get copyWith =>
      __$$EnvironmentFileImplCopyWithImpl<_$EnvironmentFileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnvironmentFileImplToJson(
      this,
    );
  }
}

abstract class _EnvironmentFile implements EnvironmentFile {
  factory _EnvironmentFile(
          {@JsonKey(name: 'file_name') required final String fileName,
          @JsonKey(name: 'date_from_filename')
          required final String dateFromFileName,
          @JsonKey(name: 'version') required final String version}) =
      _$EnvironmentFileImpl;

  factory _EnvironmentFile.fromJson(Map<String, dynamic> json) =
      _$EnvironmentFileImpl.fromJson;

  @override
  @JsonKey(name: 'file_name')
  String get fileName;
  @override
  @JsonKey(name: 'date_from_filename')
  String get dateFromFileName;
  @override
  @JsonKey(name: 'version')
  String get version;
  @override
  @JsonKey(ignore: true)
  _$$EnvironmentFileImplCopyWith<_$EnvironmentFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
