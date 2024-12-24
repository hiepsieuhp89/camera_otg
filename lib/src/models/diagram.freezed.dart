// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagram.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Diagram _$DiagramFromJson(Map<String, dynamic> json) {
  return _Diagram.fromJson(json);
}

/// @nodoc
mixin _$Diagram {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'bridge_id')
  int get bridgeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_id')
  int get photoId => throw _privateConstructorUsedError;
  Photo? get photo => throw _privateConstructorUsedError;

  /// Serializes this Diagram to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiagramCopyWith<Diagram> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagramCopyWith<$Res> {
  factory $DiagramCopyWith(Diagram value, $Res Function(Diagram) then) =
      _$DiagramCopyWithImpl<$Res, Diagram>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'bridge_id') int bridgeId,
      @JsonKey(name: 'photo_id') int photoId,
      Photo? photo});

  $PhotoCopyWith<$Res>? get photo;
}

/// @nodoc
class _$DiagramCopyWithImpl<$Res, $Val extends Diagram>
    implements $DiagramCopyWith<$Res> {
  _$DiagramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bridgeId = null,
    Object? photoId = null,
    Object? photo = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      photoId: null == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as int,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as Photo?,
    ) as $Val);
  }

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PhotoCopyWith<$Res>? get photo {
    if (_value.photo == null) {
      return null;
    }

    return $PhotoCopyWith<$Res>(_value.photo!, (value) {
      return _then(_value.copyWith(photo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiagramImplCopyWith<$Res> implements $DiagramCopyWith<$Res> {
  factory _$$DiagramImplCopyWith(
          _$DiagramImpl value, $Res Function(_$DiagramImpl) then) =
      __$$DiagramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'bridge_id') int bridgeId,
      @JsonKey(name: 'photo_id') int photoId,
      Photo? photo});

  @override
  $PhotoCopyWith<$Res>? get photo;
}

/// @nodoc
class __$$DiagramImplCopyWithImpl<$Res>
    extends _$DiagramCopyWithImpl<$Res, _$DiagramImpl>
    implements _$$DiagramImplCopyWith<$Res> {
  __$$DiagramImplCopyWithImpl(
      _$DiagramImpl _value, $Res Function(_$DiagramImpl) _then)
      : super(_value, _then);

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bridgeId = null,
    Object? photoId = null,
    Object? photo = freezed,
  }) {
    return _then(_$DiagramImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      photoId: null == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as int,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as Photo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiagramImpl implements _Diagram {
  _$DiagramImpl(
      {this.id,
      @JsonKey(name: 'bridge_id') required this.bridgeId,
      @JsonKey(name: 'photo_id') required this.photoId,
      this.photo});

  factory _$DiagramImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiagramImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'bridge_id')
  final int bridgeId;
  @override
  @JsonKey(name: 'photo_id')
  final int photoId;
  @override
  final Photo? photo;

  @override
  String toString() {
    return 'Diagram(id: $id, bridgeId: $bridgeId, photoId: $photoId, photo: $photo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bridgeId, bridgeId) ||
                other.bridgeId == bridgeId) &&
            (identical(other.photoId, photoId) || other.photoId == photoId) &&
            (identical(other.photo, photo) || other.photo == photo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, bridgeId, photoId, photo);

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagramImplCopyWith<_$DiagramImpl> get copyWith =>
      __$$DiagramImplCopyWithImpl<_$DiagramImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiagramImplToJson(
      this,
    );
  }
}

abstract class _Diagram implements Diagram {
  factory _Diagram(
      {final int? id,
      @JsonKey(name: 'bridge_id') required final int bridgeId,
      @JsonKey(name: 'photo_id') required final int photoId,
      final Photo? photo}) = _$DiagramImpl;

  factory _Diagram.fromJson(Map<String, dynamic> json) = _$DiagramImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'bridge_id')
  int get bridgeId;
  @override
  @JsonKey(name: 'photo_id')
  int get photoId;
  @override
  Photo? get photo;

  /// Create a copy of Diagram
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiagramImplCopyWith<_$DiagramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
