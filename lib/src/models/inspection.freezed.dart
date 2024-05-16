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
  @JsonKey(name: 'is_finished')
  bool get isFinished => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_imported')
  bool get isImported => throw _privateConstructorUsedError;
  @JsonKey(name: 'bridge_id')
  int get bridgeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
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
      @JsonKey(name: 'is_finished') bool isFinished,
      @JsonKey(name: 'is_imported') bool isImported,
      @JsonKey(name: 'bridge_id') int bridgeId,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
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
    Object? isFinished = null,
    Object? isImported = null,
    Object? bridgeId = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? reports = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      isImported: null == isImported
          ? _value.isImported
          : isImported // ignore: cast_nullable_to_non_nullable
              as bool,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      @JsonKey(name: 'is_finished') bool isFinished,
      @JsonKey(name: 'is_imported') bool isImported,
      @JsonKey(name: 'bridge_id') int bridgeId,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
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
    Object? isFinished = null,
    Object? isImported = null,
    Object? bridgeId = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? reports = null,
  }) {
    return _then(_$InspectionImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      isImported: null == isImported
          ? _value.isImported
          : isImported // ignore: cast_nullable_to_non_nullable
              as bool,
      bridgeId: null == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      @JsonKey(name: 'is_finished') required this.isFinished,
      @JsonKey(name: 'is_imported') required this.isImported,
      @JsonKey(name: 'bridge_id') required this.bridgeId,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      final List<InspectionPointReport> reports = const []})
      : _reports = reports;

  factory _$InspectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'is_finished')
  final bool isFinished;
  @override
  @JsonKey(name: 'is_imported')
  final bool isImported;
  @override
  @JsonKey(name: 'bridge_id')
  final int bridgeId;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
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
    return 'Inspection(id: $id, isFinished: $isFinished, isImported: $isImported, bridgeId: $bridgeId, startDate: $startDate, endDate: $endDate, reports: $reports)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.isImported, isImported) ||
                other.isImported == isImported) &&
            (identical(other.bridgeId, bridgeId) ||
                other.bridgeId == bridgeId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._reports, _reports));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      isFinished,
      isImported,
      bridgeId,
      startDate,
      endDate,
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
      @JsonKey(name: 'is_finished') required final bool isFinished,
      @JsonKey(name: 'is_imported') required final bool isImported,
      @JsonKey(name: 'bridge_id') required final int bridgeId,
      @JsonKey(name: 'start_date') final DateTime? startDate,
      @JsonKey(name: 'end_date') final DateTime? endDate,
      final List<InspectionPointReport> reports}) = _$InspectionImpl;

  factory _Inspection.fromJson(Map<String, dynamic> json) =
      _$InspectionImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'is_finished')
  bool get isFinished;
  @override
  @JsonKey(name: 'is_imported')
  bool get isImported;
  @override
  @JsonKey(name: 'bridge_id')
  int get bridgeId;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  List<InspectionPointReport> get reports;
  @override
  @JsonKey(ignore: true)
  _$$InspectionImplCopyWith<_$InspectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
