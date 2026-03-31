// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_create_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationCreateModel {

 String get email; String get taskId;
/// Create a copy of InvitationCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationCreateModelCopyWith<InvitationCreateModel> get copyWith => _$InvitationCreateModelCopyWithImpl<InvitationCreateModel>(this as InvitationCreateModel, _$identity);

  /// Serializes this InvitationCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationCreateModel&&(identical(other.email, email) || other.email == email)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,taskId);

@override
String toString() {
  return 'InvitationCreateModel(email: $email, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $InvitationCreateModelCopyWith<$Res>  {
  factory $InvitationCreateModelCopyWith(InvitationCreateModel value, $Res Function(InvitationCreateModel) _then) = _$InvitationCreateModelCopyWithImpl;
@useResult
$Res call({
 String email, String taskId
});




}
/// @nodoc
class _$InvitationCreateModelCopyWithImpl<$Res>
    implements $InvitationCreateModelCopyWith<$Res> {
  _$InvitationCreateModelCopyWithImpl(this._self, this._then);

  final InvitationCreateModel _self;
  final $Res Function(InvitationCreateModel) _then;

/// Create a copy of InvitationCreateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? taskId = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationCreateModel].
extension InvitationCreateModelPatterns on InvitationCreateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationCreateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationCreateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationCreateModel value)  $default,){
final _that = this;
switch (_that) {
case _InvitationCreateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationCreateModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationCreateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String taskId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationCreateModel() when $default != null:
return $default(_that.email,_that.taskId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String taskId)  $default,) {final _that = this;
switch (_that) {
case _InvitationCreateModel():
return $default(_that.email,_that.taskId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String taskId)?  $default,) {final _that = this;
switch (_that) {
case _InvitationCreateModel() when $default != null:
return $default(_that.email,_that.taskId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationCreateModel implements InvitationCreateModel {
  const _InvitationCreateModel({required this.email, required this.taskId});
  factory _InvitationCreateModel.fromJson(Map<String, dynamic> json) => _$InvitationCreateModelFromJson(json);

@override final  String email;
@override final  String taskId;

/// Create a copy of InvitationCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationCreateModelCopyWith<_InvitationCreateModel> get copyWith => __$InvitationCreateModelCopyWithImpl<_InvitationCreateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationCreateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationCreateModel&&(identical(other.email, email) || other.email == email)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,taskId);

@override
String toString() {
  return 'InvitationCreateModel(email: $email, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class _$InvitationCreateModelCopyWith<$Res> implements $InvitationCreateModelCopyWith<$Res> {
  factory _$InvitationCreateModelCopyWith(_InvitationCreateModel value, $Res Function(_InvitationCreateModel) _then) = __$InvitationCreateModelCopyWithImpl;
@override @useResult
$Res call({
 String email, String taskId
});




}
/// @nodoc
class __$InvitationCreateModelCopyWithImpl<$Res>
    implements _$InvitationCreateModelCopyWith<$Res> {
  __$InvitationCreateModelCopyWithImpl(this._self, this._then);

  final _InvitationCreateModel _self;
  final $Res Function(_InvitationCreateModel) _then;

/// Create a copy of InvitationCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? taskId = null,}) {
  return _then(_InvitationCreateModel(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
