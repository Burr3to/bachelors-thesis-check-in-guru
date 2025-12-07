// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_instance_create_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtaskInstanceCreateModel {

 String get templateSubtaskId; String? get assignedToUserId;
/// Create a copy of SubtaskInstanceCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskInstanceCreateModelCopyWith<SubtaskInstanceCreateModel> get copyWith => _$SubtaskInstanceCreateModelCopyWithImpl<SubtaskInstanceCreateModel>(this as SubtaskInstanceCreateModel, _$identity);

  /// Serializes this SubtaskInstanceCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskInstanceCreateModel&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateSubtaskId,assignedToUserId);

@override
String toString() {
  return 'SubtaskInstanceCreateModel(templateSubtaskId: $templateSubtaskId, assignedToUserId: $assignedToUserId)';
}


}

/// @nodoc
abstract mixin class $SubtaskInstanceCreateModelCopyWith<$Res>  {
  factory $SubtaskInstanceCreateModelCopyWith(SubtaskInstanceCreateModel value, $Res Function(SubtaskInstanceCreateModel) _then) = _$SubtaskInstanceCreateModelCopyWithImpl;
@useResult
$Res call({
 String templateSubtaskId, String? assignedToUserId
});




}
/// @nodoc
class _$SubtaskInstanceCreateModelCopyWithImpl<$Res>
    implements $SubtaskInstanceCreateModelCopyWith<$Res> {
  _$SubtaskInstanceCreateModelCopyWithImpl(this._self, this._then);

  final SubtaskInstanceCreateModel _self;
  final $Res Function(SubtaskInstanceCreateModel) _then;

/// Create a copy of SubtaskInstanceCreateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateSubtaskId = null,Object? assignedToUserId = freezed,}) {
  return _then(_self.copyWith(
templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskInstanceCreateModel].
extension SubtaskInstanceCreateModelPatterns on SubtaskInstanceCreateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskInstanceCreateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskInstanceCreateModel value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskInstanceCreateModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String templateSubtaskId,  String? assignedToUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel() when $default != null:
return $default(_that.templateSubtaskId,_that.assignedToUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String templateSubtaskId,  String? assignedToUserId)  $default,) {final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel():
return $default(_that.templateSubtaskId,_that.assignedToUserId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String templateSubtaskId,  String? assignedToUserId)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskInstanceCreateModel() when $default != null:
return $default(_that.templateSubtaskId,_that.assignedToUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtaskInstanceCreateModel implements SubtaskInstanceCreateModel {
  const _SubtaskInstanceCreateModel({required this.templateSubtaskId, this.assignedToUserId});
  factory _SubtaskInstanceCreateModel.fromJson(Map<String, dynamic> json) => _$SubtaskInstanceCreateModelFromJson(json);

@override final  String templateSubtaskId;
@override final  String? assignedToUserId;

/// Create a copy of SubtaskInstanceCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskInstanceCreateModelCopyWith<_SubtaskInstanceCreateModel> get copyWith => __$SubtaskInstanceCreateModelCopyWithImpl<_SubtaskInstanceCreateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskInstanceCreateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskInstanceCreateModel&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateSubtaskId,assignedToUserId);

@override
String toString() {
  return 'SubtaskInstanceCreateModel(templateSubtaskId: $templateSubtaskId, assignedToUserId: $assignedToUserId)';
}


}

/// @nodoc
abstract mixin class _$SubtaskInstanceCreateModelCopyWith<$Res> implements $SubtaskInstanceCreateModelCopyWith<$Res> {
  factory _$SubtaskInstanceCreateModelCopyWith(_SubtaskInstanceCreateModel value, $Res Function(_SubtaskInstanceCreateModel) _then) = __$SubtaskInstanceCreateModelCopyWithImpl;
@override @useResult
$Res call({
 String templateSubtaskId, String? assignedToUserId
});




}
/// @nodoc
class __$SubtaskInstanceCreateModelCopyWithImpl<$Res>
    implements _$SubtaskInstanceCreateModelCopyWith<$Res> {
  __$SubtaskInstanceCreateModelCopyWithImpl(this._self, this._then);

  final _SubtaskInstanceCreateModel _self;
  final $Res Function(_SubtaskInstanceCreateModel) _then;

/// Create a copy of SubtaskInstanceCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateSubtaskId = null,Object? assignedToUserId = freezed,}) {
  return _then(_SubtaskInstanceCreateModel(
templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
