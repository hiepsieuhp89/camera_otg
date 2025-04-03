// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VersionByEnvironment _$VersionByEnvironmentFromJson(Map<String, dynamic> json) {
  return _VersionByEnvironment.fromJson(json);
}

/// @nodoc
mixin _$VersionByEnvironment {
  Version? get dev => throw _privateConstructorUsedError;
  Version? get stg => throw _privateConstructorUsedError;

  /// Serializes this VersionByEnvironment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VersionByEnvironmentCopyWith<VersionByEnvironment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VersionByEnvironmentCopyWith<$Res> {
  factory $VersionByEnvironmentCopyWith(VersionByEnvironment value,
          $Res Function(VersionByEnvironment) then) =
      _$VersionByEnvironmentCopyWithImpl<$Res, VersionByEnvironment>;
  @useResult
  $Res call({Version? dev, Version? stg});

  $VersionCopyWith<$Res>? get dev;
  $VersionCopyWith<$Res>? get stg;
}

/// @nodoc
class _$VersionByEnvironmentCopyWithImpl<$Res,
        $Val extends VersionByEnvironment>
    implements $VersionByEnvironmentCopyWith<$Res> {
  _$VersionByEnvironmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
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
              as Version?,
      stg: freezed == stg
          ? _value.stg
          : stg // ignore: cast_nullable_to_non_nullable
              as Version?,
    ) as $Val);
  }

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VersionCopyWith<$Res>? get dev {
    if (_value.dev == null) {
      return null;
    }

    return $VersionCopyWith<$Res>(_value.dev!, (value) {
      return _then(_value.copyWith(dev: value) as $Val);
    });
  }

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VersionCopyWith<$Res>? get stg {
    if (_value.stg == null) {
      return null;
    }

    return $VersionCopyWith<$Res>(_value.stg!, (value) {
      return _then(_value.copyWith(stg: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VersionByEnvironmentImplCopyWith<$Res>
    implements $VersionByEnvironmentCopyWith<$Res> {
  factory _$$VersionByEnvironmentImplCopyWith(_$VersionByEnvironmentImpl value,
          $Res Function(_$VersionByEnvironmentImpl) then) =
      __$$VersionByEnvironmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Version? dev, Version? stg});

  @override
  $VersionCopyWith<$Res>? get dev;
  @override
  $VersionCopyWith<$Res>? get stg;
}

/// @nodoc
class __$$VersionByEnvironmentImplCopyWithImpl<$Res>
    extends _$VersionByEnvironmentCopyWithImpl<$Res, _$VersionByEnvironmentImpl>
    implements _$$VersionByEnvironmentImplCopyWith<$Res> {
  __$$VersionByEnvironmentImplCopyWithImpl(_$VersionByEnvironmentImpl _value,
      $Res Function(_$VersionByEnvironmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dev = freezed,
    Object? stg = freezed,
  }) {
    return _then(_$VersionByEnvironmentImpl(
      dev: freezed == dev
          ? _value.dev
          : dev // ignore: cast_nullable_to_non_nullable
              as Version?,
      stg: freezed == stg
          ? _value.stg
          : stg // ignore: cast_nullable_to_non_nullable
              as Version?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VersionByEnvironmentImpl implements _VersionByEnvironment {
  _$VersionByEnvironmentImpl({this.dev, this.stg});

  factory _$VersionByEnvironmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$VersionByEnvironmentImplFromJson(json);

  @override
  final Version? dev;
  @override
  final Version? stg;

  @override
  String toString() {
    return 'VersionByEnvironment(dev: $dev, stg: $stg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VersionByEnvironmentImpl &&
            (identical(other.dev, dev) || other.dev == dev) &&
            (identical(other.stg, stg) || other.stg == stg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, dev, stg);

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VersionByEnvironmentImplCopyWith<_$VersionByEnvironmentImpl>
      get copyWith =>
          __$$VersionByEnvironmentImplCopyWithImpl<_$VersionByEnvironmentImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VersionByEnvironmentImplToJson(
      this,
    );
  }
}

abstract class _VersionByEnvironment implements VersionByEnvironment {
  factory _VersionByEnvironment({final Version? dev, final Version? stg}) =
      _$VersionByEnvironmentImpl;

  factory _VersionByEnvironment.fromJson(Map<String, dynamic> json) =
      _$VersionByEnvironmentImpl.fromJson;

  @override
  Version? get dev;
  @override
  Version? get stg;
  @override
  Version? get prd;

  /// Create a copy of VersionByEnvironment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VersionByEnvironmentImplCopyWith<_$VersionByEnvironmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Version _$VersionFromJson(Map<String, dynamic> json) {
  return _Version.fromJson(json);
}

/// @nodoc
mixin _$Version {
  @JsonKey(name: 'download_url')
  String get downloadUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'built_at')
  DateTime get builtAt => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Serializes this Version to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VersionCopyWith<Version> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VersionCopyWith<$Res> {
  factory $VersionCopyWith(Version value, $Res Function(Version) then) =
      _$VersionCopyWithImpl<$Res, Version>;
  @useResult
  $Res call(
      {@JsonKey(name: 'download_url') String downloadUrl,
      @JsonKey(name: 'built_at') DateTime builtAt,
      String version});
}

/// @nodoc
class _$VersionCopyWithImpl<$Res, $Val extends Version>
    implements $VersionCopyWith<$Res> {
  _$VersionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloadUrl = null,
    Object? builtAt = null,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      downloadUrl: null == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      builtAt: null == builtAt
          ? _value.builtAt
          : builtAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VersionImplCopyWith<$Res> implements $VersionCopyWith<$Res> {
  factory _$$VersionImplCopyWith(
          _$VersionImpl value, $Res Function(_$VersionImpl) then) =
      __$$VersionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'download_url') String downloadUrl,
      @JsonKey(name: 'built_at') DateTime builtAt,
      String version});
}

/// @nodoc
class __$$VersionImplCopyWithImpl<$Res>
    extends _$VersionCopyWithImpl<$Res, _$VersionImpl>
    implements _$$VersionImplCopyWith<$Res> {
  __$$VersionImplCopyWithImpl(
      _$VersionImpl _value, $Res Function(_$VersionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloadUrl = null,
    Object? builtAt = null,
    Object? version = null,
  }) {
    return _then(_$VersionImpl(
      downloadUrl: null == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      builtAt: null == builtAt
          ? _value.builtAt
          : builtAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VersionImpl implements _Version {
  _$VersionImpl(
      {@JsonKey(name: 'download_url') required this.downloadUrl,
      @JsonKey(name: 'built_at') required this.builtAt,
      required this.version});

  factory _$VersionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VersionImplFromJson(json);

  @override
  @JsonKey(name: 'download_url')
  final String downloadUrl;
  @override
  @JsonKey(name: 'built_at')
  final DateTime builtAt;
  @override
  final String version;

  @override
  String toString() {
    return 'Version(downloadUrl: $downloadUrl, builtAt: $builtAt, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VersionImpl &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.builtAt, builtAt) || other.builtAt == builtAt) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, downloadUrl, builtAt, version);

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VersionImplCopyWith<_$VersionImpl> get copyWith =>
      __$$VersionImplCopyWithImpl<_$VersionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VersionImplToJson(
      this,
    );
  }
}

abstract class _Version implements Version {
  factory _Version(
      {@JsonKey(name: 'download_url') required final String downloadUrl,
      @JsonKey(name: 'built_at') required final DateTime builtAt,
      required final String version}) = _$VersionImpl;

  factory _Version.fromJson(Map<String, dynamic> json) = _$VersionImpl.fromJson;

  @override
  @JsonKey(name: 'download_url')
  String get downloadUrl;
  @override
  @JsonKey(name: 'built_at')
  DateTime get builtAt;
  @override
  String get version;

  /// Create a copy of Version
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VersionImplCopyWith<_$VersionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
