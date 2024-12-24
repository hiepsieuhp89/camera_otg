// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'municipality.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Municipality _$MunicipalityFromJson(Map<String, dynamic> json) {
  return _Municipality.fromJson(json);
}

/// @nodoc
mixin _$Municipality {
  @JsonKey(name: 'name_kanji')
  String get nameKanji => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_romaji')
  String? get nameRomaji => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_kana')
  String? get nameKana => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefecture_kanji')
  String? get prefectureKanji => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefecture_kana')
  String? get prefectureKana => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefecture_romaji')
  String? get prefectureRomaji => throw _privateConstructorUsedError;
  @JsonKey(name: 'lat')
  num? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'lon')
  num? get longitude => throw _privateConstructorUsedError;

  /// Serializes this Municipality to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Municipality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MunicipalityCopyWith<Municipality> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MunicipalityCopyWith<$Res> {
  factory $MunicipalityCopyWith(
          Municipality value, $Res Function(Municipality) then) =
      _$MunicipalityCopyWithImpl<$Res, Municipality>;
  @useResult
  $Res call(
      {@JsonKey(name: 'name_kanji') String nameKanji,
      String code,
      String? id,
      @JsonKey(name: 'name_romaji') String? nameRomaji,
      @JsonKey(name: 'name_kana') String? nameKana,
      @JsonKey(name: 'prefecture_kanji') String? prefectureKanji,
      @JsonKey(name: 'prefecture_kana') String? prefectureKana,
      @JsonKey(name: 'prefecture_romaji') String? prefectureRomaji,
      @JsonKey(name: 'lat') num? latitude,
      @JsonKey(name: 'lon') num? longitude});
}

/// @nodoc
class _$MunicipalityCopyWithImpl<$Res, $Val extends Municipality>
    implements $MunicipalityCopyWith<$Res> {
  _$MunicipalityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Municipality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nameKanji = null,
    Object? code = null,
    Object? id = freezed,
    Object? nameRomaji = freezed,
    Object? nameKana = freezed,
    Object? prefectureKanji = freezed,
    Object? prefectureKana = freezed,
    Object? prefectureRomaji = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_value.copyWith(
      nameKanji: null == nameKanji
          ? _value.nameKanji
          : nameKanji // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRomaji: freezed == nameRomaji
          ? _value.nameRomaji
          : nameRomaji // ignore: cast_nullable_to_non_nullable
              as String?,
      nameKana: freezed == nameKana
          ? _value.nameKana
          : nameKana // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureKanji: freezed == prefectureKanji
          ? _value.prefectureKanji
          : prefectureKanji // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureKana: freezed == prefectureKana
          ? _value.prefectureKana
          : prefectureKana // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureRomaji: freezed == prefectureRomaji
          ? _value.prefectureRomaji
          : prefectureRomaji // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as num?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MunicipalityImplCopyWith<$Res>
    implements $MunicipalityCopyWith<$Res> {
  factory _$$MunicipalityImplCopyWith(
          _$MunicipalityImpl value, $Res Function(_$MunicipalityImpl) then) =
      __$$MunicipalityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'name_kanji') String nameKanji,
      String code,
      String? id,
      @JsonKey(name: 'name_romaji') String? nameRomaji,
      @JsonKey(name: 'name_kana') String? nameKana,
      @JsonKey(name: 'prefecture_kanji') String? prefectureKanji,
      @JsonKey(name: 'prefecture_kana') String? prefectureKana,
      @JsonKey(name: 'prefecture_romaji') String? prefectureRomaji,
      @JsonKey(name: 'lat') num? latitude,
      @JsonKey(name: 'lon') num? longitude});
}

/// @nodoc
class __$$MunicipalityImplCopyWithImpl<$Res>
    extends _$MunicipalityCopyWithImpl<$Res, _$MunicipalityImpl>
    implements _$$MunicipalityImplCopyWith<$Res> {
  __$$MunicipalityImplCopyWithImpl(
      _$MunicipalityImpl _value, $Res Function(_$MunicipalityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Municipality
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nameKanji = null,
    Object? code = null,
    Object? id = freezed,
    Object? nameRomaji = freezed,
    Object? nameKana = freezed,
    Object? prefectureKanji = freezed,
    Object? prefectureKana = freezed,
    Object? prefectureRomaji = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$MunicipalityImpl(
      nameKanji: null == nameKanji
          ? _value.nameKanji
          : nameKanji // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRomaji: freezed == nameRomaji
          ? _value.nameRomaji
          : nameRomaji // ignore: cast_nullable_to_non_nullable
              as String?,
      nameKana: freezed == nameKana
          ? _value.nameKana
          : nameKana // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureKanji: freezed == prefectureKanji
          ? _value.prefectureKanji
          : prefectureKanji // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureKana: freezed == prefectureKana
          ? _value.prefectureKana
          : prefectureKana // ignore: cast_nullable_to_non_nullable
              as String?,
      prefectureRomaji: freezed == prefectureRomaji
          ? _value.prefectureRomaji
          : prefectureRomaji // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as num?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MunicipalityImpl implements _Municipality {
  _$MunicipalityImpl(
      {@JsonKey(name: 'name_kanji') required this.nameKanji,
      required this.code,
      this.id,
      @JsonKey(name: 'name_romaji') this.nameRomaji,
      @JsonKey(name: 'name_kana') this.nameKana,
      @JsonKey(name: 'prefecture_kanji') this.prefectureKanji,
      @JsonKey(name: 'prefecture_kana') this.prefectureKana,
      @JsonKey(name: 'prefecture_romaji') this.prefectureRomaji,
      @JsonKey(name: 'lat') this.latitude,
      @JsonKey(name: 'lon') this.longitude});

  factory _$MunicipalityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MunicipalityImplFromJson(json);

  @override
  @JsonKey(name: 'name_kanji')
  final String nameKanji;
  @override
  final String code;
  @override
  final String? id;
  @override
  @JsonKey(name: 'name_romaji')
  final String? nameRomaji;
  @override
  @JsonKey(name: 'name_kana')
  final String? nameKana;
  @override
  @JsonKey(name: 'prefecture_kanji')
  final String? prefectureKanji;
  @override
  @JsonKey(name: 'prefecture_kana')
  final String? prefectureKana;
  @override
  @JsonKey(name: 'prefecture_romaji')
  final String? prefectureRomaji;
  @override
  @JsonKey(name: 'lat')
  final num? latitude;
  @override
  @JsonKey(name: 'lon')
  final num? longitude;

  @override
  String toString() {
    return 'Municipality(nameKanji: $nameKanji, code: $code, id: $id, nameRomaji: $nameRomaji, nameKana: $nameKana, prefectureKanji: $prefectureKanji, prefectureKana: $prefectureKana, prefectureRomaji: $prefectureRomaji, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MunicipalityImpl &&
            (identical(other.nameKanji, nameKanji) ||
                other.nameKanji == nameKanji) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameRomaji, nameRomaji) ||
                other.nameRomaji == nameRomaji) &&
            (identical(other.nameKana, nameKana) ||
                other.nameKana == nameKana) &&
            (identical(other.prefectureKanji, prefectureKanji) ||
                other.prefectureKanji == prefectureKanji) &&
            (identical(other.prefectureKana, prefectureKana) ||
                other.prefectureKana == prefectureKana) &&
            (identical(other.prefectureRomaji, prefectureRomaji) ||
                other.prefectureRomaji == prefectureRomaji) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      nameKanji,
      code,
      id,
      nameRomaji,
      nameKana,
      prefectureKanji,
      prefectureKana,
      prefectureRomaji,
      latitude,
      longitude);

  /// Create a copy of Municipality
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MunicipalityImplCopyWith<_$MunicipalityImpl> get copyWith =>
      __$$MunicipalityImplCopyWithImpl<_$MunicipalityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MunicipalityImplToJson(
      this,
    );
  }
}

abstract class _Municipality implements Municipality {
  factory _Municipality(
      {@JsonKey(name: 'name_kanji') required final String nameKanji,
      required final String code,
      final String? id,
      @JsonKey(name: 'name_romaji') final String? nameRomaji,
      @JsonKey(name: 'name_kana') final String? nameKana,
      @JsonKey(name: 'prefecture_kanji') final String? prefectureKanji,
      @JsonKey(name: 'prefecture_kana') final String? prefectureKana,
      @JsonKey(name: 'prefecture_romaji') final String? prefectureRomaji,
      @JsonKey(name: 'lat') final num? latitude,
      @JsonKey(name: 'lon') final num? longitude}) = _$MunicipalityImpl;

  factory _Municipality.fromJson(Map<String, dynamic> json) =
      _$MunicipalityImpl.fromJson;

  @override
  @JsonKey(name: 'name_kanji')
  String get nameKanji;
  @override
  String get code;
  @override
  String? get id;
  @override
  @JsonKey(name: 'name_romaji')
  String? get nameRomaji;
  @override
  @JsonKey(name: 'name_kana')
  String? get nameKana;
  @override
  @JsonKey(name: 'prefecture_kanji')
  String? get prefectureKanji;
  @override
  @JsonKey(name: 'prefecture_kana')
  String? get prefectureKana;
  @override
  @JsonKey(name: 'prefecture_romaji')
  String? get prefectureRomaji;
  @override
  @JsonKey(name: 'lat')
  num? get latitude;
  @override
  @JsonKey(name: 'lon')
  num? get longitude;

  /// Create a copy of Municipality
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MunicipalityImplCopyWith<_$MunicipalityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
