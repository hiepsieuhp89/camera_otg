// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contractor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Contractor _$ContractorFromJson(Map<String, dynamic> json) {
  return _Contractor.fromJson(json);
}

/// @nodoc
mixin _$Contractor {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_jp')
  String get nameJp => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_en')
  String get nameEn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContractorCopyWith<Contractor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContractorCopyWith<$Res> {
  factory $ContractorCopyWith(
          Contractor value, $Res Function(Contractor) then) =
      _$ContractorCopyWithImpl<$Res, Contractor>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'name_jp') String nameJp,
      @JsonKey(name: 'name_en') String nameEn});
}

/// @nodoc
class _$ContractorCopyWithImpl<$Res, $Val extends Contractor>
    implements $ContractorCopyWith<$Res> {
  _$ContractorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameJp = null,
    Object? nameEn = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ContractorImplCopyWith<$Res>
    implements $ContractorCopyWith<$Res> {
  factory _$$ContractorImplCopyWith(
          _$ContractorImpl value, $Res Function(_$ContractorImpl) then) =
      __$$ContractorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'name_jp') String nameJp,
      @JsonKey(name: 'name_en') String nameEn});
}

/// @nodoc
class __$$ContractorImplCopyWithImpl<$Res>
    extends _$ContractorCopyWithImpl<$Res, _$ContractorImpl>
    implements _$$ContractorImplCopyWith<$Res> {
  __$$ContractorImplCopyWithImpl(
      _$ContractorImpl _value, $Res Function(_$ContractorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameJp = null,
    Object? nameEn = null,
  }) {
    return _then(_$ContractorImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ContractorImpl implements _Contractor {
  _$ContractorImpl(
      {required this.id,
      @JsonKey(name: 'name_jp') required this.nameJp,
      @JsonKey(name: 'name_en') required this.nameEn});

  factory _$ContractorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContractorImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'name_jp')
  final String nameJp;
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;

  @override
  String toString() {
    return 'Contractor(id: $id, nameJp: $nameJp, nameEn: $nameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContractorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameJp, nameJp) || other.nameJp == nameJp) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameJp, nameEn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContractorImplCopyWith<_$ContractorImpl> get copyWith =>
      __$$ContractorImplCopyWithImpl<_$ContractorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContractorImplToJson(
      this,
    );
  }
}

abstract class _Contractor implements Contractor {
  factory _Contractor(
          {required final int id,
          @JsonKey(name: 'name_jp') required final String nameJp,
          @JsonKey(name: 'name_en') required final String nameEn}) =
      _$ContractorImpl;

  factory _Contractor.fromJson(Map<String, dynamic> json) =
      _$ContractorImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'name_jp')
  String get nameJp;
  @override
  @JsonKey(name: 'name_en')
  String get nameEn;
  @override
  @JsonKey(ignore: true)
  _$$ContractorImplCopyWith<_$ContractorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
