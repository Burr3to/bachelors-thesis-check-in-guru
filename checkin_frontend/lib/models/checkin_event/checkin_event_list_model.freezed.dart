// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkin_event_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CheckInEventListModel _$CheckInEventListModelFromJson(
  Map<String, dynamic> json,
) {
  return _CheckInEventListModel.fromJson(json);
}

/// @nodoc
mixin _$CheckInEventListModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get hash => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;

  /// Serializes this CheckInEventListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInEventListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInEventListModelCopyWith<CheckInEventListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInEventListModelCopyWith<$Res> {
  factory $CheckInEventListModelCopyWith(
    CheckInEventListModel value,
    $Res Function(CheckInEventListModel) then,
  ) = _$CheckInEventListModelCopyWithImpl<$Res, CheckInEventListModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String hash,
    DateTime createdAt,
    String ownerId,
  });
}

/// @nodoc
class _$CheckInEventListModelCopyWithImpl<
  $Res,
  $Val extends CheckInEventListModel
>
    implements $CheckInEventListModelCopyWith<$Res> {
  _$CheckInEventListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInEventListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hash = null,
    Object? createdAt = null,
    Object? ownerId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            hash: null == hash
                ? _value.hash
                : hash // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CheckInEventListModelImplCopyWith<$Res>
    implements $CheckInEventListModelCopyWith<$Res> {
  factory _$$CheckInEventListModelImplCopyWith(
    _$CheckInEventListModelImpl value,
    $Res Function(_$CheckInEventListModelImpl) then,
  ) = __$$CheckInEventListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String hash,
    DateTime createdAt,
    String ownerId,
  });
}

/// @nodoc
class __$$CheckInEventListModelImplCopyWithImpl<$Res>
    extends
        _$CheckInEventListModelCopyWithImpl<$Res, _$CheckInEventListModelImpl>
    implements _$$CheckInEventListModelImplCopyWith<$Res> {
  __$$CheckInEventListModelImplCopyWithImpl(
    _$CheckInEventListModelImpl _value,
    $Res Function(_$CheckInEventListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckInEventListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hash = null,
    Object? createdAt = null,
    Object? ownerId = null,
  }) {
    return _then(
      _$CheckInEventListModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        hash: null == hash
            ? _value.hash
            : hash // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInEventListModelImpl implements _CheckInEventListModel {
  const _$CheckInEventListModelImpl({
    required this.id,
    required this.title,
    required this.hash,
    required this.createdAt,
    required this.ownerId,
  });

  factory _$CheckInEventListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInEventListModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String hash;
  @override
  final DateTime createdAt;
  @override
  final String ownerId;

  @override
  String toString() {
    return 'CheckInEventListModel(id: $id, title: $title, hash: $hash, createdAt: $createdAt, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInEventListModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, hash, createdAt, ownerId);

  /// Create a copy of CheckInEventListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInEventListModelImplCopyWith<_$CheckInEventListModelImpl>
  get copyWith =>
      __$$CheckInEventListModelImplCopyWithImpl<_$CheckInEventListModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInEventListModelImplToJson(this);
  }
}

abstract class _CheckInEventListModel implements CheckInEventListModel {
  const factory _CheckInEventListModel({
    required final String id,
    required final String title,
    required final String hash,
    required final DateTime createdAt,
    required final String ownerId,
  }) = _$CheckInEventListModelImpl;

  factory _CheckInEventListModel.fromJson(Map<String, dynamic> json) =
      _$CheckInEventListModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get hash;
  @override
  DateTime get createdAt;
  @override
  String get ownerId;

  /// Create a copy of CheckInEventListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInEventListModelImplCopyWith<_$CheckInEventListModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
