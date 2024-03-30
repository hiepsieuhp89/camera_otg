// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Inspection _$InspectionFromJson(Map<String, dynamic> json) {
  return _Inspection.fromJson(json);
}

/// @nodoc
mixin _$Inspection {
  int? get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'bridge_id')
  int get bridgeId => throw _privateConstructorUsedError;
  List<InspectionPointReport> get reports => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionCopyWith<Inspection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionCopyWith<$Res> {
  factory $InspectionCopyWith(
          Inspection value, $Res Function(Inspection) then) =
      _$InspectionCopyWithImpl<$Res, Inspection>;
  @useResult
  $Res call(
      {int? id,
      DateTime timestamp,
      @JsonKey(name: 'bridge_id') int bridgeId,
      List<InspectionPointReport> reports});
}

/// @nodoc
class _$InspectionCopyWithImpl<$Res, $Val extends Inspection>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? timestamp = null,
    Object? bridgeId = null,
    Object? reports = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      reports: null == reports
          ? _value.reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<InspectionPointReport>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InspectionImplCopyWith<$Res>
    implements $InspectionCopyWith<$Res> {
  factory _$$InspectionImplCopyWith(
          _$InspectionImpl value, $Res Function(_$InspectionImpl) then) =
      __$$InspectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      DateTime timestamp,
      @JsonKey(name: 'bridge_id') int bridgeId,
      List<InspectionPointReport> reports});
}

/// @nodoc
class __$$InspectionImplCopyWithImpl<$Res>
    extends _$InspectionCopyWithImpl<$Res, _$InspectionImpl>
    implements _$$InspectionImplCopyWith<$Res> {
  __$$InspectionImplCopyWithImpl(
      _$InspectionImpl _value, $Res Function(_$InspectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? timestamp = null,
    Object? bridgeId = null,
    Object? reports = null,
  }) {
    return _then(_$InspectionImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      reports: null == reports
          ? _value._reports
          : reports // ignore: cast_nullable_to_non_nullable
              as List<InspectionPointReport>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionImpl implements _Inspection {
  _$InspectionImpl(
      {this.id,
      required this.timestamp,
      @JsonKey(name: 'bridge_id') required this.bridgeId,
      final List<InspectionPointReport> reports = const []})
      : _reports = reports;

  factory _$InspectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionImplFromJson(json);

  @override
  final int? id;
  @override
  final DateTime timestamp;
  @override
  @JsonKey(name: 'bridge_id')
  final int bridgeId;
  final List<InspectionPointReport> _reports;
  @override
  @JsonKey()
  List<InspectionPointReport> get reports {
    if (_reports is EqualUnmodifiableListView) return _reports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reports);
  }

  @override
  String toString() {
    return 'Inspection(id: $id, timestamp: $timestamp, bridgeId: $bridgeId, reports: $reports)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.bridgeId, bridgeId) ||
                other.bridgeId == bridgeId) &&
            const DeepCollectionEquality().equals(other._reports, _reports));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, timestamp, bridgeId,
      const DeepCollectionEquality().hash(_reports));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionImplCopyWith<_$InspectionImpl> get copyWith =>
      __$$InspectionImplCopyWithImpl<_$InspectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InspectionImplToJson(
      this,
    );
  }
}

abstract class _Inspection implements Inspection {
  factory _Inspection(
      {final int? id,
      required final DateTime timestamp,
      @JsonKey(name: 'bridge_id') required final int bridgeId,
      final List<InspectionPointReport> reports}) = _$InspectionImpl;

  factory _Inspection.fromJson(Map<String, dynamic> json) =
      _$InspectionImpl.fromJson;

  @override
  int? get id;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(name: 'bridge_id')
  int get bridgeId;
  @override
  List<InspectionPointReport> get reports;
  @override
  @JsonKey(ignore: true)
  _$$InspectionImplCopyWith<_$InspectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
