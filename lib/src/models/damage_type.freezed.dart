// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'damage_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DamageType _$DamageTypeFromJson(Map<String, dynamic> json) {
  return _DamageType.fromJson(json);
}

/// @nodoc
mixin _$DamageType {
  int get id => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_jp')
  String get nameJp => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_en')
  String get nameEn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DamageTypeCopyWith<DamageType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DamageTypeCopyWith<$Res> {
  factory $DamageTypeCopyWith(
          DamageType value, $Res Function(DamageType) then) =
      _$DamageTypeCopyWithImpl<$Res, DamageType>;
  @useResult
  $Res call(
      {int id,
      String category,
      @JsonKey(name: 'name_jp') String nameJp,
      @JsonKey(name: 'name_en') String nameEn});
}

/// @nodoc
class _$DamageTypeCopyWithImpl<$Res, $Val extends DamageType>
    implements $DamageTypeCopyWith<$Res> {
  _$DamageTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? nameJp = null,
    Object? nameEn = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      nameJp: null == nameJp
          ? _value.nameJp
          : nameJp // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DamageTypeImplCopyWith<$Res>
    implements $DamageTypeCopyWith<$Res> {
  factory _$$DamageTypeImplCopyWith(
          _$DamageTypeImpl value, $Res Function(_$DamageTypeImpl) then) =
      __$$DamageTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String category,
      @JsonKey(name: 'name_jp') String nameJp,
      @JsonKey(name: 'name_en') String nameEn});
}

/// @nodoc
class __$$DamageTypeImplCopyWithImpl<$Res>
    extends _$DamageTypeCopyWithImpl<$Res, _$DamageTypeImpl>
    implements _$$DamageTypeImplCopyWith<$Res> {
  __$$DamageTypeImplCopyWithImpl(
      _$DamageTypeImpl _value, $Res Function(_$DamageTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? nameJp = null,
    Object? nameEn = null,
  }) {
    return _then(_$DamageTypeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      nameJp: null == nameJp
          ? _value.nameJp
          : nameJp // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DamageTypeImpl implements _DamageType {
  _$DamageTypeImpl(
      {required this.id,
      required this.category,
      @JsonKey(name: 'name_jp') required this.nameJp,
      @JsonKey(name: 'name_en') required this.nameEn});

  factory _$DamageTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DamageTypeImplFromJson(json);

  @override
  final int id;
  @override
  final String category;
  @override
  @JsonKey(name: 'name_jp')
  final String nameJp;
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;

  @override
  String toString() {
    return 'DamageType(id: $id, category: $category, nameJp: $nameJp, nameEn: $nameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DamageTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.nameJp, nameJp) || other.nameJp == nameJp) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, category, nameJp, nameEn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DamageTypeImplCopyWith<_$DamageTypeImpl> get copyWith =>
      __$$DamageTypeImplCopyWithImpl<_$DamageTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DamageTypeImplToJson(
      this,
    );
  }
}

abstract class _DamageType implements DamageType {
  factory _DamageType(
          {required final int id,
          required final String category,
          @JsonKey(name: 'name_jp') required final String nameJp,
          @JsonKey(name: 'name_en') required final String nameEn}) =
      _$DamageTypeImpl;

  factory _DamageType.fromJson(Map<String, dynamic> json) =
      _$DamageTypeImpl.fromJson;

  @override
  int get id;
  @override
  String get category;
  @override
  @JsonKey(name: 'name_jp')
  String get nameJp;
  @override
  @JsonKey(name: 'name_en')
  String get nameEn;
  @override
  @JsonKey(ignore: true)
  _$$DamageTypeImplCopyWith<_$DamageTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
