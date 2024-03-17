// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_point_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InspectionPointReport _$InspectionPointReportFromJson(
    Map<String, dynamic> json) {
  return _InspectionPointReport.fromJson(json);
}

/// @nodoc
mixin _$InspectionPointReport {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'inspection_point_id')
  int get inspectionPointId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date')
  DateTime? get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionPointReportCopyWith<InspectionPointReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionPointReportCopyWith<$Res> {
  factory $InspectionPointReportCopyWith(InspectionPointReport value,
          $Res Function(InspectionPointReport) then) =
      _$InspectionPointReportCopyWithImpl<$Res, InspectionPointReport>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'inspection_point_id') int inspectionPointId,
      @JsonKey(name: 'date') DateTime? date});
}

/// @nodoc
class _$InspectionPointReportCopyWithImpl<$Res,
        $Val extends InspectionPointReport>
    implements $InspectionPointReportCopyWith<$Res> {
  _$InspectionPointReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? inspectionPointId = null,
    Object? date = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      inspectionPointId: null == inspectionPointId
          ? _value.inspectionPointId
          : inspectionPointId // ignore: cast_nullable_to_non_nullable
              as int,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InspectionPointReportImplCopyWith<$Res>
    implements $InspectionPointReportCopyWith<$Res> {
  factory _$$InspectionPointReportImplCopyWith(
          _$InspectionPointReportImpl value,
          $Res Function(_$InspectionPointReportImpl) then) =
      __$$InspectionPointReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'inspection_point_id') int inspectionPointId,
      @JsonKey(name: 'date') DateTime? date});
}

/// @nodoc
class __$$InspectionPointReportImplCopyWithImpl<$Res>
    extends _$InspectionPointReportCopyWithImpl<$Res,
        _$InspectionPointReportImpl>
    implements _$$InspectionPointReportImplCopyWith<$Res> {
  __$$InspectionPointReportImplCopyWithImpl(_$InspectionPointReportImpl _value,
      $Res Function(_$InspectionPointReportImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? inspectionPointId = null,
    Object? date = freezed,
  }) {
    return _then(_$InspectionPointReportImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      inspectionPointId: null == inspectionPointId
          ? _value.inspectionPointId
          : inspectionPointId // ignore: cast_nullable_to_non_nullable
              as int,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionPointReportImpl implements _InspectionPointReport {
  _$InspectionPointReportImpl(
      {this.id,
      @JsonKey(name: 'inspection_point_id') required this.inspectionPointId,
      @JsonKey(name: 'date') this.date});

  factory _$InspectionPointReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionPointReportImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'inspection_point_id')
  final int inspectionPointId;
  @override
  @JsonKey(name: 'date')
  final DateTime? date;

  @override
  String toString() {
    return 'InspectionPointReport(id: $id, inspectionPointId: $inspectionPointId, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionPointReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inspectionPointId, inspectionPointId) ||
                other.inspectionPointId == inspectionPointId) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, inspectionPointId, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionPointReportImplCopyWith<_$InspectionPointReportImpl>
      get copyWith => __$$InspectionPointReportImplCopyWithImpl<
          _$InspectionPointReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InspectionPointReportImplToJson(
      this,
    );
  }
}

abstract class _InspectionPointReport implements InspectionPointReport {
  factory _InspectionPointReport(
          {final int? id,
          @JsonKey(name: 'inspection_point_id')
          required final int inspectionPointId,
          @JsonKey(name: 'date') final DateTime? date}) =
      _$InspectionPointReportImpl;

  factory _InspectionPointReport.fromJson(Map<String, dynamic> json) =
      _$InspectionPointReportImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'inspection_point_id')
  int get inspectionPointId;
  @override
  @JsonKey(name: 'date')
  DateTime? get date;
  @override
  @JsonKey(ignore: true)
  _$$InspectionPointReportImplCopyWith<_$InspectionPointReportImpl>
      get copyWith => throw _privateConstructorUsedError;
}
