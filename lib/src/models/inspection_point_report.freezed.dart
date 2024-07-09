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
  InspectionPointReportStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'inspection_point_id')
  int get inspectionPointId => throw _privateConstructorUsedError;
  @JsonKey(name: 'inspection_id')
  int get inspectionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_photo_id')
  int? get preferredPhotoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'meta_data')
  dynamic get metadata => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  List<Photo> get photos => throw _privateConstructorUsedError;

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
      InspectionPointReportStatus status,
      @JsonKey(name: 'inspection_point_id') int inspectionPointId,
      @JsonKey(name: 'inspection_id') int inspectionId,
      @JsonKey(name: 'preferred_photo_id') int? preferredPhotoId,
      @JsonKey(name: 'meta_data') dynamic metadata,
      DateTime? date,
      List<Photo> photos});
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
    Object? status = null,
    Object? inspectionPointId = null,
    Object? inspectionId = null,
    Object? preferredPhotoId = freezed,
    Object? metadata = freezed,
    Object? date = freezed,
    Object? photos = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InspectionPointReportStatus,
      inspectionPointId: null == inspectionPointId
          ? _value.inspectionPointId
          : inspectionPointId // ignore: cast_nullable_to_non_nullable
              as int,
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as int,
      preferredPhotoId: freezed == preferredPhotoId
          ? _value.preferredPhotoId
          : preferredPhotoId // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as dynamic,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>,
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
      InspectionPointReportStatus status,
      @JsonKey(name: 'inspection_point_id') int inspectionPointId,
      @JsonKey(name: 'inspection_id') int inspectionId,
      @JsonKey(name: 'preferred_photo_id') int? preferredPhotoId,
      @JsonKey(name: 'meta_data') dynamic metadata,
      DateTime? date,
      List<Photo> photos});
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
    Object? status = null,
    Object? inspectionPointId = null,
    Object? inspectionId = null,
    Object? preferredPhotoId = freezed,
    Object? metadata = freezed,
    Object? date = freezed,
    Object? photos = null,
  }) {
    return _then(_$InspectionPointReportImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InspectionPointReportStatus,
      inspectionPointId: null == inspectionPointId
          ? _value.inspectionPointId
          : inspectionPointId // ignore: cast_nullable_to_non_nullable
              as int,
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as int,
      preferredPhotoId: freezed == preferredPhotoId
          ? _value.preferredPhotoId
          : preferredPhotoId // ignore: cast_nullable_to_non_nullable
              as int?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as dynamic,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionPointReportImpl implements _InspectionPointReport {
  _$InspectionPointReportImpl(
      {this.id,
      this.status = InspectionPointReportStatus.finished,
      @JsonKey(name: 'inspection_point_id') required this.inspectionPointId,
      @JsonKey(name: 'inspection_id') required this.inspectionId,
      @JsonKey(name: 'preferred_photo_id') this.preferredPhotoId,
      @JsonKey(name: 'meta_data') this.metadata,
      this.date,
      final List<Photo> photos = const []})
      : _photos = photos;

  factory _$InspectionPointReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$InspectionPointReportImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey()
  final InspectionPointReportStatus status;
  @override
  @JsonKey(name: 'inspection_point_id')
  final int inspectionPointId;
  @override
  @JsonKey(name: 'inspection_id')
  final int inspectionId;
  @override
  @JsonKey(name: 'preferred_photo_id')
  final int? preferredPhotoId;
  @override
  @JsonKey(name: 'meta_data')
  final dynamic metadata;
  @override
  final DateTime? date;
  final List<Photo> _photos;
  @override
  @JsonKey()
  List<Photo> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  String toString() {
    return 'InspectionPointReport(id: $id, status: $status, inspectionPointId: $inspectionPointId, inspectionId: $inspectionId, preferredPhotoId: $preferredPhotoId, metadata: $metadata, date: $date, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionPointReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.inspectionPointId, inspectionPointId) ||
                other.inspectionPointId == inspectionPointId) &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.preferredPhotoId, preferredPhotoId) ||
                other.preferredPhotoId == preferredPhotoId) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      inspectionPointId,
      inspectionId,
      preferredPhotoId,
      const DeepCollectionEquality().hash(metadata),
      date,
      const DeepCollectionEquality().hash(_photos));

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
      final InspectionPointReportStatus status,
      @JsonKey(name: 'inspection_point_id')
      required final int inspectionPointId,
      @JsonKey(name: 'inspection_id') required final int inspectionId,
      @JsonKey(name: 'preferred_photo_id') final int? preferredPhotoId,
      @JsonKey(name: 'meta_data') final dynamic metadata,
      final DateTime? date,
      final List<Photo> photos}) = _$InspectionPointReportImpl;

  factory _InspectionPointReport.fromJson(Map<String, dynamic> json) =
      _$InspectionPointReportImpl.fromJson;

  @override
  int? get id;
  @override
  InspectionPointReportStatus get status;
  @override
  @JsonKey(name: 'inspection_point_id')
  int get inspectionPointId;
  @override
  @JsonKey(name: 'inspection_id')
  int get inspectionId;
  @override
  @JsonKey(name: 'preferred_photo_id')
  int? get preferredPhotoId;
  @override
  @JsonKey(name: 'meta_data')
  dynamic get metadata;
  @override
  DateTime? get date;
  @override
  List<Photo> get photos;
  @override
  @JsonKey(ignore: true)
  _$$InspectionPointReportImplCopyWith<_$InspectionPointReportImpl>
      get copyWith => throw _privateConstructorUsedError;
}
