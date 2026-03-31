// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_instance_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtaskInstanceListModel {

 String get id; String get responseGroupId;// <--- PRIDAŤ SEM
 String get templateSubtaskId; String? get assignedToUserId; bool get isCompleted; String? get completedByUserId; String? get assignedToEmail; DateTime? get completedAt;
/// Create a copy of SubtaskInstanceListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskInstanceListModelCopyWith<SubtaskInstanceListModel> get copyWith => _$SubtaskInstanceListModelCopyWithImpl<SubtaskInstanceListModel>(this as SubtaskInstanceListModel, _$identity);

  /// Serializes this SubtaskInstanceListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskInstanceListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.responseGroupId, responseGroupId) || other.responseGroupId == responseGroupId)&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.assignedToEmail, assignedToEmail) || other.assignedToEmail == assignedToEmail)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,responseGroupId,templateSubtaskId,assignedToUserId,isCompleted,completedByUserId,assignedToEmail,completedAt);

@override
String toString() {
  return 'SubtaskInstanceListModel(id: $id, responseGroupId: $responseGroupId, templateSubtaskId: $templateSubtaskId, assignedToUserId: $assignedToUserId, isCompleted: $isCompleted, completedByUserId: $completedByUserId, assignedToEmail: $assignedToEmail, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $SubtaskInstanceListModelCopyWith<$Res>  {
  factory $SubtaskInstanceListModelCopyWith(SubtaskInstanceListModel value, $Res Function(SubtaskInstanceListModel) _then) = _$SubtaskInstanceListModelCopyWithImpl;
@useResult
$Res call({
 String id, String responseGroupId, String templateSubtaskId, String? assignedToUserId, bool isCompleted, String? completedByUserId, String? assignedToEmail, DateTime? completedAt
});




}
/// @nodoc
class _$SubtaskInstanceListModelCopyWithImpl<$Res>
    implements $SubtaskInstanceListModelCopyWith<$Res> {
  _$SubtaskInstanceListModelCopyWithImpl(this._self, this._then);

  final SubtaskInstanceListModel _self;
  final $Res Function(SubtaskInstanceListModel) _then;

/// Create a copy of SubtaskInstanceListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? responseGroupId = null,Object? templateSubtaskId = null,Object? assignedToUserId = freezed,Object? isCompleted = null,Object? completedByUserId = freezed,Object? assignedToEmail = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,responseGroupId: null == responseGroupId ? _self.responseGroupId : responseGroupId // ignore: cast_nullable_to_non_nullable
as String,templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,assignedToEmail: freezed == assignedToEmail ? _self.assignedToEmail : assignedToEmail // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskInstanceListModel].
extension SubtaskInstanceListModelPatterns on SubtaskInstanceListModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskInstanceListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskInstanceListModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskInstanceListModel value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskInstanceListModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskInstanceListModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskInstanceListModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String responseGroupId,  String templateSubtaskId,  String? assignedToUserId,  bool isCompleted,  String? completedByUserId,  String? assignedToEmail,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskInstanceListModel() when $default != null:
return $default(_that.id,_that.responseGroupId,_that.templateSubtaskId,_that.assignedToUserId,_that.isCompleted,_that.completedByUserId,_that.assignedToEmail,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String responseGroupId,  String templateSubtaskId,  String? assignedToUserId,  bool isCompleted,  String? completedByUserId,  String? assignedToEmail,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _SubtaskInstanceListModel():
return $default(_that.id,_that.responseGroupId,_that.templateSubtaskId,_that.assignedToUserId,_that.isCompleted,_that.completedByUserId,_that.assignedToEmail,_that.completedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String responseGroupId,  String templateSubtaskId,  String? assignedToUserId,  bool isCompleted,  String? completedByUserId,  String? assignedToEmail,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskInstanceListModel() when $default != null:
return $default(_that.id,_that.responseGroupId,_that.templateSubtaskId,_that.assignedToUserId,_that.isCompleted,_that.completedByUserId,_that.assignedToEmail,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtaskInstanceListModel implements SubtaskInstanceListModel {
  const _SubtaskInstanceListModel({required this.id, required this.responseGroupId, required this.templateSubtaskId, this.assignedToUserId, this.isCompleted = false, this.completedByUserId, this.assignedToEmail, this.completedAt});
  factory _SubtaskInstanceListModel.fromJson(Map<String, dynamic> json) => _$SubtaskInstanceListModelFromJson(json);

@override final  String id;
@override final  String responseGroupId;
// <--- PRIDAŤ SEM
@override final  String templateSubtaskId;
@override final  String? assignedToUserId;
@override@JsonKey() final  bool isCompleted;
@override final  String? completedByUserId;
@override final  String? assignedToEmail;
@override final  DateTime? completedAt;

/// Create a copy of SubtaskInstanceListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskInstanceListModelCopyWith<_SubtaskInstanceListModel> get copyWith => __$SubtaskInstanceListModelCopyWithImpl<_SubtaskInstanceListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskInstanceListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskInstanceListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.responseGroupId, responseGroupId) || other.responseGroupId == responseGroupId)&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.assignedToEmail, assignedToEmail) || other.assignedToEmail == assignedToEmail)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,responseGroupId,templateSubtaskId,assignedToUserId,isCompleted,completedByUserId,assignedToEmail,completedAt);

@override
String toString() {
  return 'SubtaskInstanceListModel(id: $id, responseGroupId: $responseGroupId, templateSubtaskId: $templateSubtaskId, assignedToUserId: $assignedToUserId, isCompleted: $isCompleted, completedByUserId: $completedByUserId, assignedToEmail: $assignedToEmail, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SubtaskInstanceListModelCopyWith<$Res> implements $SubtaskInstanceListModelCopyWith<$Res> {
  factory _$SubtaskInstanceListModelCopyWith(_SubtaskInstanceListModel value, $Res Function(_SubtaskInstanceListModel) _then) = __$SubtaskInstanceListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String responseGroupId, String templateSubtaskId, String? assignedToUserId, bool isCompleted, String? completedByUserId, String? assignedToEmail, DateTime? completedAt
});




}
/// @nodoc
class __$SubtaskInstanceListModelCopyWithImpl<$Res>
    implements _$SubtaskInstanceListModelCopyWith<$Res> {
  __$SubtaskInstanceListModelCopyWithImpl(this._self, this._then);

  final _SubtaskInstanceListModel _self;
  final $Res Function(_SubtaskInstanceListModel) _then;

/// Create a copy of SubtaskInstanceListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? responseGroupId = null,Object? templateSubtaskId = null,Object? assignedToUserId = freezed,Object? isCompleted = null,Object? completedByUserId = freezed,Object? assignedToEmail = freezed,Object? completedAt = freezed,}) {
  return _then(_SubtaskInstanceListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,responseGroupId: null == responseGroupId ? _self.responseGroupId : responseGroupId // ignore: cast_nullable_to_non_nullable
as String,templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,assignedToEmail: freezed == assignedToEmail ? _self.assignedToEmail : assignedToEmail // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
