// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvitationListModel {

 String get id; String get email; String get taskId; bool get isAccepted; DateTime get sentAt;
/// Create a copy of InvitationListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitationListModelCopyWith<InvitationListModel> get copyWith => _$InvitationListModelCopyWithImpl<InvitationListModel>(this as InvitationListModel, _$identity);

  /// Serializes this InvitationListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvitationListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,taskId,isAccepted,sentAt);

@override
String toString() {
  return 'InvitationListModel(id: $id, email: $email, taskId: $taskId, isAccepted: $isAccepted, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class $InvitationListModelCopyWith<$Res>  {
  factory $InvitationListModelCopyWith(InvitationListModel value, $Res Function(InvitationListModel) _then) = _$InvitationListModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, String taskId, bool isAccepted, DateTime sentAt
});




}
/// @nodoc
class _$InvitationListModelCopyWithImpl<$Res>
    implements $InvitationListModelCopyWith<$Res> {
  _$InvitationListModelCopyWithImpl(this._self, this._then);

  final InvitationListModel _self;
  final $Res Function(InvitationListModel) _then;

/// Create a copy of InvitationListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? taskId = null,Object? isAccepted = null,Object? sentAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvitationListModel].
extension InvitationListModelPatterns on InvitationListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvitationListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvitationListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvitationListModel value)  $default,){
final _that = this;
switch (_that) {
case _InvitationListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvitationListModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvitationListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String taskId,  bool isAccepted,  DateTime sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvitationListModel() when $default != null:
return $default(_that.id,_that.email,_that.taskId,_that.isAccepted,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String taskId,  bool isAccepted,  DateTime sentAt)  $default,) {final _that = this;
switch (_that) {
case _InvitationListModel():
return $default(_that.id,_that.email,_that.taskId,_that.isAccepted,_that.sentAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String taskId,  bool isAccepted,  DateTime sentAt)?  $default,) {final _that = this;
switch (_that) {
case _InvitationListModel() when $default != null:
return $default(_that.id,_that.email,_that.taskId,_that.isAccepted,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvitationListModel implements InvitationListModel {
  const _InvitationListModel({required this.id, required this.email, required this.taskId, required this.isAccepted, required this.sentAt});
  factory _InvitationListModel.fromJson(Map<String, dynamic> json) => _$InvitationListModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  String taskId;
@override final  bool isAccepted;
@override final  DateTime sentAt;

/// Create a copy of InvitationListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitationListModelCopyWith<_InvitationListModel> get copyWith => __$InvitationListModelCopyWithImpl<_InvitationListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitationListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvitationListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,taskId,isAccepted,sentAt);

@override
String toString() {
  return 'InvitationListModel(id: $id, email: $email, taskId: $taskId, isAccepted: $isAccepted, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$InvitationListModelCopyWith<$Res> implements $InvitationListModelCopyWith<$Res> {
  factory _$InvitationListModelCopyWith(_InvitationListModel value, $Res Function(_InvitationListModel) _then) = __$InvitationListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String taskId, bool isAccepted, DateTime sentAt
});




}
/// @nodoc
class __$InvitationListModelCopyWithImpl<$Res>
    implements _$InvitationListModelCopyWith<$Res> {
  __$InvitationListModelCopyWithImpl(this._self, this._then);

  final _InvitationListModel _self;
  final $Res Function(_InvitationListModel) _then;

/// Create a copy of InvitationListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? taskId = null,Object? isAccepted = null,Object? sentAt = null,}) {
  return _then(_InvitationListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
