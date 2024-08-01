// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InspectionPoint _$InspectionPointFromJson(Map<String, dynamic> json) {
  return _InpsectionPoint.fromJson(json);
}

/// @nodoc
mixin _$InspectionPoint {
  int? get id => throw _privateConstructorUsedError;
  InspectionPointType get type => throw _privateConstructorUsedError;
  Diagram? get diagram => throw _privateConstructorUsedError;
  @JsonKey(name: 'bridge_id')
  int? get bridgeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'diagram_url')
  String? get diagramUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'diagram_id')
  int? get diagramId => throw _privateConstructorUsedError;
  @JsonKey(name: 'diagram_marking_x')
  int? get diagramMarkingX => throw _privateConstructorUsedError;
  @JsonKey(name: 'diagram_marking_y')
  int? get diagramMarkingY => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_ref_number')
  int? get photoRefNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'span_name')
  String? get spanName => throw _privateConstructorUsedError;
  @JsonKey(name: 'span_number')
  String? get spanNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'element_number')
  String? get elementNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'diagram_marked_photo_link')
  String? get diagramMarkedPhotoLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_inspection_date')
  DateTime? get lastInspectionDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InspectionPointCopyWith<InspectionPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionPointCopyWith<$Res> {
  factory $InspectionPointCopyWith(
          InspectionPoint value, $Res Function(InspectionPoint) then) =
      _$InspectionPointCopyWithImpl<$Res, InspectionPoint>;
  @useResult
  $Res call(
      {int? id,
      InspectionPointType type,
      Diagram? diagram,
      @JsonKey(name: 'bridge_id') int? bridgeId,
      @JsonKey(name: 'diagram_url') String? diagramUrl,
      @JsonKey(name: 'diagram_id') int? diagramId,
      @JsonKey(name: 'diagram_marking_x') int? diagramMarkingX,
      @JsonKey(name: 'diagram_marking_y') int? diagramMarkingY,
      @JsonKey(name: 'photo_ref_number') int? photoRefNumber,
      @JsonKey(name: 'span_name') String? spanName,
      @JsonKey(name: 'span_number') String? spanNumber,
      @JsonKey(name: 'element_number') String? elementNumber,
      @JsonKey(name: 'diagram_marked_photo_link')
      String? diagramMarkedPhotoLink,
      @JsonKey(name: 'last_inspection_date') DateTime? lastInspectionDate});

  $DiagramCopyWith<$Res>? get diagram;
}

/// @nodoc
class _$InspectionPointCopyWithImpl<$Res, $Val extends InspectionPoint>
    implements $InspectionPointCopyWith<$Res> {
  _$InspectionPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? diagram = freezed,
    Object? bridgeId = freezed,
    Object? diagramUrl = freezed,
    Object? diagramId = freezed,
    Object? diagramMarkingX = freezed,
    Object? diagramMarkingY = freezed,
    Object? photoRefNumber = freezed,
    Object? spanName = freezed,
    Object? spanNumber = freezed,
    Object? elementNumber = freezed,
    Object? diagramMarkedPhotoLink = freezed,
    Object? lastInspectionDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InspectionPointType,
      diagram: freezed == diagram
          ? _value.diagram
          : diagram // ignore: cast_nullable_to_non_nullable
              as Diagram?,
      bridgeId: freezed == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramUrl: freezed == diagramUrl
          ? _value.diagramUrl
          : diagramUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      diagramId: freezed == diagramId
          ? _value.diagramId
          : diagramId // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramMarkingX: freezed == diagramMarkingX
          ? _value.diagramMarkingX
          : diagramMarkingX // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramMarkingY: freezed == diagramMarkingY
          ? _value.diagramMarkingY
          : diagramMarkingY // ignore: cast_nullable_to_non_nullable
              as int?,
      photoRefNumber: freezed == photoRefNumber
          ? _value.photoRefNumber
          : photoRefNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      spanName: freezed == spanName
          ? _value.spanName
          : spanName // ignore: cast_nullable_to_non_nullable
              as String?,
      spanNumber: freezed == spanNumber
          ? _value.spanNumber
          : spanNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      elementNumber: freezed == elementNumber
          ? _value.elementNumber
          : elementNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      diagramMarkedPhotoLink: freezed == diagramMarkedPhotoLink
          ? _value.diagramMarkedPhotoLink
          : diagramMarkedPhotoLink // ignore: cast_nullable_to_non_nullable
              as String?,
      lastInspectionDate: freezed == lastInspectionDate
          ? _value.lastInspectionDate
          : lastInspectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DiagramCopyWith<$Res>? get diagram {
    if (_value.diagram == null) {
      return null;
    }

    return $DiagramCopyWith<$Res>(_value.diagram!, (value) {
      return _then(_value.copyWith(diagram: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InpsectionPointImplCopyWith<$Res>
    implements $InspectionPointCopyWith<$Res> {
  factory _$$InpsectionPointImplCopyWith(_$InpsectionPointImpl value,
          $Res Function(_$InpsectionPointImpl) then) =
      __$$InpsectionPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      InspectionPointType type,
      Diagram? diagram,
      @JsonKey(name: 'bridge_id') int? bridgeId,
      @JsonKey(name: 'diagram_url') String? diagramUrl,
      @JsonKey(name: 'diagram_id') int? diagramId,
      @JsonKey(name: 'diagram_marking_x') int? diagramMarkingX,
      @JsonKey(name: 'diagram_marking_y') int? diagramMarkingY,
      @JsonKey(name: 'photo_ref_number') int? photoRefNumber,
      @JsonKey(name: 'span_name') String? spanName,
      @JsonKey(name: 'span_number') String? spanNumber,
      @JsonKey(name: 'element_number') String? elementNumber,
      @JsonKey(name: 'diagram_marked_photo_link')
      String? diagramMarkedPhotoLink,
      @JsonKey(name: 'last_inspection_date') DateTime? lastInspectionDate});

  @override
  $DiagramCopyWith<$Res>? get diagram;
}

/// @nodoc
class __$$InpsectionPointImplCopyWithImpl<$Res>
    extends _$InspectionPointCopyWithImpl<$Res, _$InpsectionPointImpl>
    implements _$$InpsectionPointImplCopyWith<$Res> {
  __$$InpsectionPointImplCopyWithImpl(
      _$InpsectionPointImpl _value, $Res Function(_$InpsectionPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = null,
    Object? diagram = freezed,
    Object? bridgeId = freezed,
    Object? diagramUrl = freezed,
    Object? diagramId = freezed,
    Object? diagramMarkingX = freezed,
    Object? diagramMarkingY = freezed,
    Object? photoRefNumber = freezed,
    Object? spanName = freezed,
    Object? spanNumber = freezed,
    Object? elementNumber = freezed,
    Object? diagramMarkedPhotoLink = freezed,
    Object? lastInspectionDate = freezed,
  }) {
    return _then(_$InpsectionPointImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InspectionPointType,
      diagram: freezed == diagram
          ? _value.diagram
          : diagram // ignore: cast_nullable_to_non_nullable
              as Diagram?,
      bridgeId: freezed == bridgeId
          ? _value.bridgeId
          : bridgeId // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramUrl: freezed == diagramUrl
          ? _value.diagramUrl
          : diagramUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      diagramId: freezed == diagramId
          ? _value.diagramId
          : diagramId // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramMarkingX: freezed == diagramMarkingX
          ? _value.diagramMarkingX
          : diagramMarkingX // ignore: cast_nullable_to_non_nullable
              as int?,
      diagramMarkingY: freezed == diagramMarkingY
          ? _value.diagramMarkingY
          : diagramMarkingY // ignore: cast_nullable_to_non_nullable
              as int?,
      photoRefNumber: freezed == photoRefNumber
          ? _value.photoRefNumber
          : photoRefNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      spanName: freezed == spanName
          ? _value.spanName
          : spanName // ignore: cast_nullable_to_non_nullable
              as String?,
      spanNumber: freezed == spanNumber
          ? _value.spanNumber
          : spanNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      elementNumber: freezed == elementNumber
          ? _value.elementNumber
          : elementNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      diagramMarkedPhotoLink: freezed == diagramMarkedPhotoLink
          ? _value.diagramMarkedPhotoLink
          : diagramMarkedPhotoLink // ignore: cast_nullable_to_non_nullable
              as String?,
      lastInspectionDate: freezed == lastInspectionDate
          ? _value.lastInspectionDate
          : lastInspectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InpsectionPointImpl implements _InpsectionPoint {
  _$InpsectionPointImpl(
      {this.id,
      required this.type,
      this.diagram,
      @JsonKey(name: 'bridge_id') this.bridgeId,
      @JsonKey(name: 'diagram_url') this.diagramUrl,
      @JsonKey(name: 'diagram_id') this.diagramId,
      @JsonKey(name: 'diagram_marking_x') this.diagramMarkingX,
      @JsonKey(name: 'diagram_marking_y') this.diagramMarkingY,
      @JsonKey(name: 'photo_ref_number') this.photoRefNumber,
      @JsonKey(name: 'span_name') this.spanName,
      @JsonKey(name: 'span_number') this.spanNumber,
      @JsonKey(name: 'element_number') this.elementNumber,
      @JsonKey(name: 'diagram_marked_photo_link') this.diagramMarkedPhotoLink,
      @JsonKey(name: 'last_inspection_date') this.lastInspectionDate});

  factory _$InpsectionPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$InpsectionPointImplFromJson(json);

  @override
  final int? id;
  @override
  final InspectionPointType type;
  @override
  final Diagram? diagram;
  @override
  @JsonKey(name: 'bridge_id')
  final int? bridgeId;
  @override
  @JsonKey(name: 'diagram_url')
  final String? diagramUrl;
  @override
  @JsonKey(name: 'diagram_id')
  final int? diagramId;
  @override
  @JsonKey(name: 'diagram_marking_x')
  final int? diagramMarkingX;
  @override
  @JsonKey(name: 'diagram_marking_y')
  final int? diagramMarkingY;
  @override
  @JsonKey(name: 'photo_ref_number')
  final int? photoRefNumber;
  @override
  @JsonKey(name: 'span_name')
  final String? spanName;
  @override
  @JsonKey(name: 'span_number')
  final String? spanNumber;
  @override
  @JsonKey(name: 'element_number')
  final String? elementNumber;
  @override
  @JsonKey(name: 'diagram_marked_photo_link')
  final String? diagramMarkedPhotoLink;
  @override
  @JsonKey(name: 'last_inspection_date')
  final DateTime? lastInspectionDate;

  @override
  String toString() {
    return 'InspectionPoint(id: $id, type: $type, diagram: $diagram, bridgeId: $bridgeId, diagramUrl: $diagramUrl, diagramId: $diagramId, diagramMarkingX: $diagramMarkingX, diagramMarkingY: $diagramMarkingY, photoRefNumber: $photoRefNumber, spanName: $spanName, spanNumber: $spanNumber, elementNumber: $elementNumber, diagramMarkedPhotoLink: $diagramMarkedPhotoLink, lastInspectionDate: $lastInspectionDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InpsectionPointImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.diagram, diagram) || other.diagram == diagram) &&
            (identical(other.bridgeId, bridgeId) ||
                other.bridgeId == bridgeId) &&
            (identical(other.diagramUrl, diagramUrl) ||
                other.diagramUrl == diagramUrl) &&
            (identical(other.diagramId, diagramId) ||
                other.diagramId == diagramId) &&
            (identical(other.diagramMarkingX, diagramMarkingX) ||
                other.diagramMarkingX == diagramMarkingX) &&
            (identical(other.diagramMarkingY, diagramMarkingY) ||
                other.diagramMarkingY == diagramMarkingY) &&
            (identical(other.photoRefNumber, photoRefNumber) ||
                other.photoRefNumber == photoRefNumber) &&
            (identical(other.spanName, spanName) ||
                other.spanName == spanName) &&
            (identical(other.spanNumber, spanNumber) ||
                other.spanNumber == spanNumber) &&
            (identical(other.elementNumber, elementNumber) ||
                other.elementNumber == elementNumber) &&
            (identical(other.diagramMarkedPhotoLink, diagramMarkedPhotoLink) ||
                other.diagramMarkedPhotoLink == diagramMarkedPhotoLink) &&
            (identical(other.lastInspectionDate, lastInspectionDate) ||
                other.lastInspectionDate == lastInspectionDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      diagram,
      bridgeId,
      diagramUrl,
      diagramId,
      diagramMarkingX,
      diagramMarkingY,
      photoRefNumber,
      spanName,
      spanNumber,
      elementNumber,
      diagramMarkedPhotoLink,
      lastInspectionDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InpsectionPointImplCopyWith<_$InpsectionPointImpl> get copyWith =>
      __$$InpsectionPointImplCopyWithImpl<_$InpsectionPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InpsectionPointImplToJson(
      this,
    );
  }
}

abstract class _InpsectionPoint implements InspectionPoint {
  factory _InpsectionPoint(
      {final int? id,
      required final InspectionPointType type,
      final Diagram? diagram,
      @JsonKey(name: 'bridge_id') final int? bridgeId,
      @JsonKey(name: 'diagram_url') final String? diagramUrl,
      @JsonKey(name: 'diagram_id') final int? diagramId,
      @JsonKey(name: 'diagram_marking_x') final int? diagramMarkingX,
      @JsonKey(name: 'diagram_marking_y') final int? diagramMarkingY,
      @JsonKey(name: 'photo_ref_number') final int? photoRefNumber,
      @JsonKey(name: 'span_name') final String? spanName,
      @JsonKey(name: 'span_number') final String? spanNumber,
      @JsonKey(name: 'element_number') final String? elementNumber,
      @JsonKey(name: 'diagram_marked_photo_link')
      final String? diagramMarkedPhotoLink,
      @JsonKey(name: 'last_inspection_date')
      final DateTime? lastInspectionDate}) = _$InpsectionPointImpl;

  factory _InpsectionPoint.fromJson(Map<String, dynamic> json) =
      _$InpsectionPointImpl.fromJson;

  @override
  int? get id;
  @override
  InspectionPointType get type;
  @override
  Diagram? get diagram;
  @override
  @JsonKey(name: 'bridge_id')
  int? get bridgeId;
  @override
  @JsonKey(name: 'diagram_url')
  String? get diagramUrl;
  @override
  @JsonKey(name: 'diagram_id')
  int? get diagramId;
  @override
  @JsonKey(name: 'diagram_marking_x')
  int? get diagramMarkingX;
  @override
  @JsonKey(name: 'diagram_marking_y')
  int? get diagramMarkingY;
  @override
  @JsonKey(name: 'photo_ref_number')
  int? get photoRefNumber;
  @override
  @JsonKey(name: 'span_name')
  String? get spanName;
  @override
  @JsonKey(name: 'span_number')
  String? get spanNumber;
  @override
  @JsonKey(name: 'element_number')
  String? get elementNumber;
  @override
  @JsonKey(name: 'diagram_marked_photo_link')
  String? get diagramMarkedPhotoLink;
  @override
  @JsonKey(name: 'last_inspection_date')
  DateTime? get lastInspectionDate;
  @override
  @JsonKey(ignore: true)
  _$$InpsectionPointImplCopyWith<_$InpsectionPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
