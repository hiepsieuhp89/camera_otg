// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bridge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Bridge _$BridgeFromJson(Map<String, dynamic> json) {
  return _Bridge.fromJson(json);
}

/// @nodoc
mixin _$Bridge {
  int get id => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  @JsonKey(name: 'bridge_no')
  String get bridgeNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'management_no')
  String get managementNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_kana')
  String? get nameKana => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_link')
  String get photoLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_kanji')
  String get nameKanji => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_inspection_date')
  DateTime? get lastInspectionDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BridgeCopyWith<Bridge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BridgeCopyWith<$Res> {
  factory $BridgeCopyWith(Bridge value, $Res Function(Bridge) then) =
      _$BridgeCopyWithImpl<$Res, Bridge>;
  @useResult
  $Res call(
      {int id,
      String? condition,
      @JsonKey(name: 'bridge_no') String bridgeNo,
      @JsonKey(name: 'management_no') String managementNo,
      @JsonKey(name: 'name_kana') String? nameKana,
      @JsonKey(name: 'photo_link') String photoLink,
      @JsonKey(name: 'name_kanji') String nameKanji,
      @JsonKey(name: 'last_inspection_date') DateTime? lastInspectionDate});
}

/// @nodoc
class _$BridgeCopyWithImpl<$Res, $Val extends Bridge>
    implements $BridgeCopyWith<$Res> {
  _$BridgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? condition = freezed,
    Object? bridgeNo = null,
    Object? managementNo = null,
    Object? nameKana = freezed,
    Object? photoLink = null,
    Object? nameKanji = null,
    Object? lastInspectionDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      bridgeNo: null == bridgeNo
          ? _value.bridgeNo
          : bridgeNo // ignore: cast_nullable_to_non_nullable
              as String,
      managementNo: null == managementNo
          ? _value.managementNo
          : managementNo // ignore: cast_nullable_to_non_nullable
              as String,
      nameKana: freezed == nameKana
          ? _value.nameKana
          : nameKana // ignore: cast_nullable_to_non_nullable
              as String?,
      photoLink: null == photoLink
          ? _value.photoLink
          : photoLink // ignore: cast_nullable_to_non_nullable
              as String,
      nameKanji: null == nameKanji
          ? _value.nameKanji
          : nameKanji // ignore: cast_nullable_to_non_nullable
              as String,
      lastInspectionDate: freezed == lastInspectionDate
          ? _value.lastInspectionDate
          : lastInspectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BridgeImplCopyWith<$Res> implements $BridgeCopyWith<$Res> {
  factory _$$BridgeImplCopyWith(
          _$BridgeImpl value, $Res Function(_$BridgeImpl) then) =
      __$$BridgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? condition,
      @JsonKey(name: 'bridge_no') String bridgeNo,
      @JsonKey(name: 'management_no') String managementNo,
      @JsonKey(name: 'name_kana') String? nameKana,
      @JsonKey(name: 'photo_link') String photoLink,
      @JsonKey(name: 'name_kanji') String nameKanji,
      @JsonKey(name: 'last_inspection_date') DateTime? lastInspectionDate});
}

/// @nodoc
class __$$BridgeImplCopyWithImpl<$Res>
    extends _$BridgeCopyWithImpl<$Res, _$BridgeImpl>
    implements _$$BridgeImplCopyWith<$Res> {
  __$$BridgeImplCopyWithImpl(
      _$BridgeImpl _value, $Res Function(_$BridgeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? condition = freezed,
    Object? bridgeNo = null,
    Object? managementNo = null,
    Object? nameKana = freezed,
    Object? photoLink = null,
    Object? nameKanji = null,
    Object? lastInspectionDate = freezed,
  }) {
    return _then(_$BridgeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      bridgeNo: null == bridgeNo
          ? _value.bridgeNo
          : bridgeNo // ignore: cast_nullable_to_non_nullable
              as String,
      managementNo: null == managementNo
          ? _value.managementNo
          : managementNo // ignore: cast_nullable_to_non_nullable
              as String,
      nameKana: freezed == nameKana
          ? _value.nameKana
          : nameKana // ignore: cast_nullable_to_non_nullable
              as String?,
      photoLink: null == photoLink
          ? _value.photoLink
          : photoLink // ignore: cast_nullable_to_non_nullable
              as String,
      nameKanji: null == nameKanji
          ? _value.nameKanji
          : nameKanji // ignore: cast_nullable_to_non_nullable
              as String,
      lastInspectionDate: freezed == lastInspectionDate
          ? _value.lastInspectionDate
          : lastInspectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BridgeImpl implements _Bridge {
  _$BridgeImpl(
      {required this.id,
      this.condition,
      @JsonKey(name: 'bridge_no') required this.bridgeNo,
      @JsonKey(name: 'management_no') required this.managementNo,
      @JsonKey(name: 'name_kana') this.nameKana,
      @JsonKey(name: 'photo_link') required this.photoLink,
      @JsonKey(name: 'name_kanji') required this.nameKanji,
      @JsonKey(name: 'last_inspection_date') this.lastInspectionDate});

  factory _$BridgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BridgeImplFromJson(json);

  @override
  final int id;
  @override
  final String? condition;
  @override
  @JsonKey(name: 'bridge_no')
  final String bridgeNo;
  @override
  @JsonKey(name: 'management_no')
  final String managementNo;
  @override
  @JsonKey(name: 'name_kana')
  final String? nameKana;
  @override
  @JsonKey(name: 'photo_link')
  final String photoLink;
  @override
  @JsonKey(name: 'name_kanji')
  final String nameKanji;
  @override
  @JsonKey(name: 'last_inspection_date')
  final DateTime? lastInspectionDate;

  @override
  String toString() {
    return 'Bridge(id: $id, condition: $condition, bridgeNo: $bridgeNo, managementNo: $managementNo, nameKana: $nameKana, photoLink: $photoLink, nameKanji: $nameKanji, lastInspectionDate: $lastInspectionDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BridgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.bridgeNo, bridgeNo) ||
                other.bridgeNo == bridgeNo) &&
            (identical(other.managementNo, managementNo) ||
                other.managementNo == managementNo) &&
            (identical(other.nameKana, nameKana) ||
                other.nameKana == nameKana) &&
            (identical(other.photoLink, photoLink) ||
                other.photoLink == photoLink) &&
            (identical(other.nameKanji, nameKanji) ||
                other.nameKanji == nameKanji) &&
            (identical(other.lastInspectionDate, lastInspectionDate) ||
                other.lastInspectionDate == lastInspectionDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, condition, bridgeNo,
      managementNo, nameKana, photoLink, nameKanji, lastInspectionDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BridgeImplCopyWith<_$BridgeImpl> get copyWith =>
      __$$BridgeImplCopyWithImpl<_$BridgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BridgeImplToJson(
      this,
    );
  }
}

abstract class _Bridge implements Bridge {
  factory _Bridge(
      {required final int id,
      final String? condition,
      @JsonKey(name: 'bridge_no') required final String bridgeNo,
      @JsonKey(name: 'management_no') required final String managementNo,
      @JsonKey(name: 'name_kana') final String? nameKana,
      @JsonKey(name: 'photo_link') required final String photoLink,
      @JsonKey(name: 'name_kanji') required final String nameKanji,
      @JsonKey(name: 'last_inspection_date')
      final DateTime? lastInspectionDate}) = _$BridgeImpl;

  factory _Bridge.fromJson(Map<String, dynamic> json) = _$BridgeImpl.fromJson;

  @override
  int get id;
  @override
  String? get condition;
  @override
  @JsonKey(name: 'bridge_no')
  String get bridgeNo;
  @override
  @JsonKey(name: 'management_no')
  String get managementNo;
  @override
  @JsonKey(name: 'name_kana')
  String? get nameKana;
  @override
  @JsonKey(name: 'photo_link')
  String get photoLink;
  @override
  @JsonKey(name: 'name_kanji')
  String get nameKanji;
  @override
  @JsonKey(name: 'last_inspection_date')
  DateTime? get lastInspectionDate;
  @override
  @JsonKey(ignore: true)
  _$$BridgeImplCopyWith<_$BridgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
