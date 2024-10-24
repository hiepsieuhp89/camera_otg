// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_point_report_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InspectionPointReportPhoto _$InspectionPointReportPhotoFromJson(
    Map<String, dynamic> json) {
  return _InspectionPointReportPhoto.fromJson(json);
}

/// @nodoc
mixin _$InspectionPointReportPhoto {
  String? get localPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_link')
  String? get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_id')
  int? get photoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_sequence_number')
  int? get sequenceNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_id')
  int? get reportId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionPointReportPhotoCopyWith<InspectionPointReportPhoto>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionPointReportPhotoCopyWith<$Res> {
  factory $InspectionPointReportPhotoCopyWith(InspectionPointReportPhoto value,
          $Res Function(InspectionPointReportPhoto) then) =
      _$InspectionPointReportPhotoCopyWithImpl<$Res,
          InspectionPointReportPhoto>;
  @useResult
  $Res call(
      {String? localPath,
      @JsonKey(name: 'photo_link') String? url,
      @JsonKey(name: 'photo_id') int? photoId,
      @JsonKey(name: 'photo_sequence_number') int? sequenceNumber,
      @JsonKey(name: 'report_id') int? reportId});
}

/// @nodoc
class _$InspectionPointReportPhotoCopyWithImpl<$Res,
        $Val extends InspectionPointReportPhoto>
    implements $InspectionPointReportPhotoCopyWith<$Res> {
  _$InspectionPointReportPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localPath = freezed,
    Object? url = freezed,
    Object? photoId = freezed,
    Object? sequenceNumber = freezed,
    Object? reportId = freezed,
  }) {
    return _then(_value.copyWith(
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      photoId: freezed == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as int?,
      sequenceNumber: freezed == sequenceNumber
          ? _value.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      reportId: freezed == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InspectionPointReportPhotoImplCopyWith<$Res>
    implements $InspectionPointReportPhotoCopyWith<$Res> {
  factory _$$InspectionPointReportPhotoImplCopyWith(
          _$InspectionPointReportPhotoImpl value,
          $Res Function(_$InspectionPointReportPhotoImpl) then) =
      __$$InspectionPointReportPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? localPath,
      @JsonKey(name: 'photo_link') String? url,
      @JsonKey(name: 'photo_id') int? photoId,
      @JsonKey(name: 'photo_sequence_number') int? sequenceNumber,
      @JsonKey(name: 'report_id') int? reportId});
}

/// @nodoc
class __$$InspectionPointReportPhotoImplCopyWithImpl<$Res>
    extends _$InspectionPointReportPhotoCopyWithImpl<$Res,
        _$InspectionPointReportPhotoImpl>
    implements _$$InspectionPointReportPhotoImplCopyWith<$Res> {
  __$$InspectionPointReportPhotoImplCopyWithImpl(
      _$InspectionPointReportPhotoImpl _value,
      $Res Function(_$InspectionPointReportPhotoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localPath = freezed,
    Object? url = freezed,
    Object? photoId = freezed,
    Object? sequenceNumber = freezed,
    Object? reportId = freezed,
  }) {
    return _then(_$InspectionPointReportPhotoImpl(
      localPath: freezed == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      photoId: freezed == photoId
          ? _value.photoId
          : photoId // ignore: cast_nullable_to_non_nullable
              as int?,
      sequenceNumber: freezed == sequenceNumber
          ? _value.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      reportId: freezed == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InspectionPointReportPhotoImpl implements _InspectionPointReportPhoto {
  _$InspectionPointReportPhotoImpl(
      {this.localPath,
      @JsonKey(name: 'photo_link') this.url,
      @JsonKey(name: 'photo_id') this.photoId,
      @JsonKey(name: 'photo_sequence_number') this.sequenceNumber,
      @JsonKey(name: 'report_id') this.reportId});

  factory _$InspectionPointReportPhotoImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$InspectionPointReportPhotoImplFromJson(json);

  @override
  final String? localPath;
  @override
  @JsonKey(name: 'photo_link')
  final String? url;
  @override
  @JsonKey(name: 'photo_id')
  final int? photoId;
  @override
  @JsonKey(name: 'photo_sequence_number')
  final int? sequenceNumber;
  @override
  @JsonKey(name: 'report_id')
  final int? reportId;

  @override
  String toString() {
    return 'InspectionPointReportPhoto(localPath: $localPath, url: $url, photoId: $photoId, sequenceNumber: $sequenceNumber, reportId: $reportId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionPointReportPhotoImpl &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.photoId, photoId) || other.photoId == photoId) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, localPath, url, photoId, sequenceNumber, reportId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionPointReportPhotoImplCopyWith<_$InspectionPointReportPhotoImpl>
      get copyWith => __$$InspectionPointReportPhotoImplCopyWithImpl<
          _$InspectionPointReportPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InspectionPointReportPhotoImplToJson(
      this,
    );
  }
}

abstract class _InspectionPointReportPhoto
    implements InspectionPointReportPhoto {
  factory _InspectionPointReportPhoto(
          {final String? localPath,
          @JsonKey(name: 'photo_link') final String? url,
          @JsonKey(name: 'photo_id') final int? photoId,
          @JsonKey(name: 'photo_sequence_number') final int? sequenceNumber,
          @JsonKey(name: 'report_id') final int? reportId}) =
      _$InspectionPointReportPhotoImpl;

  factory _InspectionPointReportPhoto.fromJson(Map<String, dynamic> json) =
      _$InspectionPointReportPhotoImpl.fromJson;

  @override
  String? get localPath;
  @override
  @JsonKey(name: 'photo_link')
  String? get url;
  @override
  @JsonKey(name: 'photo_id')
  int? get photoId;
  @override
  @JsonKey(name: 'photo_sequence_number')
  int? get sequenceNumber;
  @override
  @JsonKey(name: 'report_id')
  int? get reportId;
  @override
  @JsonKey(ignore: true)
  _$$InspectionPointReportPhotoImplCopyWith<_$InspectionPointReportPhotoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
