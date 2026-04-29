// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_create_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskCreateModel {

 String get title; String? get notes; DateTime get deadLine; SubtaskMode get subtaskMode; bool get requiresAuthenticationToComplete; List<SubtaskTemplateCreateModel> get subtasks; List<String> get invitedEmails; bool get sendInvitesImmediately; String? get allowedDomain;@JsonKey(includeToJson: false) bool? get isDomainValid;
/// Create a copy of TaskCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCreateModelCopyWith<TaskCreateModel> get copyWith => _$TaskCreateModelCopyWithImpl<TaskCreateModel>(this as TaskCreateModel, _$identity);

  /// Serializes this TaskCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&const DeepCollectionEquality().equals(other.invitedEmails, invitedEmails)&&(identical(other.sendInvitesImmediately, sendInvitesImmediately) || other.sendInvitesImmediately == sendInvitesImmediately)&&(identical(other.allowedDomain, allowedDomain) || other.allowedDomain == allowedDomain)&&(identical(other.isDomainValid, isDomainValid) || other.isDomainValid == isDomainValid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,notes,deadLine,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(subtasks),const DeepCollectionEquality().hash(invitedEmails),sendInvitesImmediately,allowedDomain,isDomainValid);

@override
String toString() {
  return 'TaskCreateModel(title: $title, notes: $notes, deadLine: $deadLine, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks, invitedEmails: $invitedEmails, sendInvitesImmediately: $sendInvitesImmediately, allowedDomain: $allowedDomain, isDomainValid: $isDomainValid)';
}


}

/// @nodoc
abstract mixin class $TaskCreateModelCopyWith<$Res>  {
  factory $TaskCreateModelCopyWith(TaskCreateModel value, $Res Function(TaskCreateModel) _then) = _$TaskCreateModelCopyWithImpl;
@useResult
$Res call({
 String title, String? notes, DateTime deadLine, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskTemplateCreateModel> subtasks, List<String> invitedEmails, bool sendInvitesImmediately, String? allowedDomain,@JsonKey(includeToJson: false) bool? isDomainValid
});




}
/// @nodoc
class _$TaskCreateModelCopyWithImpl<$Res>
    implements $TaskCreateModelCopyWith<$Res> {
  _$TaskCreateModelCopyWithImpl(this._self, this._then);

  final TaskCreateModel _self;
  final $Res Function(TaskCreateModel) _then;

/// Create a copy of TaskCreateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? notes = freezed,Object? deadLine = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,Object? invitedEmails = null,Object? sendInvitesImmediately = null,Object? allowedDomain = freezed,Object? isDomainValid = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateCreateModel>,invitedEmails: null == invitedEmails ? _self.invitedEmails : invitedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,sendInvitesImmediately: null == sendInvitesImmediately ? _self.sendInvitesImmediately : sendInvitesImmediately // ignore: cast_nullable_to_non_nullable
as bool,allowedDomain: freezed == allowedDomain ? _self.allowedDomain : allowedDomain // ignore: cast_nullable_to_non_nullable
as String?,isDomainValid: freezed == isDomainValid ? _self.isDomainValid : isDomainValid // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskCreateModel].
extension TaskCreateModelPatterns on TaskCreateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskCreateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskCreateModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskCreateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskCreateModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? notes,  DateTime deadLine,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateCreateModel> subtasks,  List<String> invitedEmails,  bool sendInvitesImmediately,  String? allowedDomain, @JsonKey(includeToJson: false)  bool? isDomainValid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
return $default(_that.title,_that.notes,_that.deadLine,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.invitedEmails,_that.sendInvitesImmediately,_that.allowedDomain,_that.isDomainValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? notes,  DateTime deadLine,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateCreateModel> subtasks,  List<String> invitedEmails,  bool sendInvitesImmediately,  String? allowedDomain, @JsonKey(includeToJson: false)  bool? isDomainValid)  $default,) {final _that = this;
switch (_that) {
case _TaskCreateModel():
return $default(_that.title,_that.notes,_that.deadLine,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.invitedEmails,_that.sendInvitesImmediately,_that.allowedDomain,_that.isDomainValid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? notes,  DateTime deadLine,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateCreateModel> subtasks,  List<String> invitedEmails,  bool sendInvitesImmediately,  String? allowedDomain, @JsonKey(includeToJson: false)  bool? isDomainValid)?  $default,) {final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
return $default(_that.title,_that.notes,_that.deadLine,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.invitedEmails,_that.sendInvitesImmediately,_that.allowedDomain,_that.isDomainValid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskCreateModel implements TaskCreateModel {
  const _TaskCreateModel({required this.title, this.notes, required this.deadLine, required this.subtaskMode, this.requiresAuthenticationToComplete = true, final  List<SubtaskTemplateCreateModel> subtasks = const [], final  List<String> invitedEmails = const [], this.sendInvitesImmediately = false, this.allowedDomain, @JsonKey(includeToJson: false) this.isDomainValid = null}): _subtasks = subtasks,_invitedEmails = invitedEmails;
  factory _TaskCreateModel.fromJson(Map<String, dynamic> json) => _$TaskCreateModelFromJson(json);

@override final  String title;
@override final  String? notes;
@override final  DateTime deadLine;
@override final  SubtaskMode subtaskMode;
@override@JsonKey() final  bool requiresAuthenticationToComplete;
 final  List<SubtaskTemplateCreateModel> _subtasks;
@override@JsonKey() List<SubtaskTemplateCreateModel> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

 final  List<String> _invitedEmails;
@override@JsonKey() List<String> get invitedEmails {
  if (_invitedEmails is EqualUnmodifiableListView) return _invitedEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitedEmails);
}

@override@JsonKey() final  bool sendInvitesImmediately;
@override final  String? allowedDomain;
@override@JsonKey(includeToJson: false) final  bool? isDomainValid;

/// Create a copy of TaskCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCreateModelCopyWith<_TaskCreateModel> get copyWith => __$TaskCreateModelCopyWithImpl<_TaskCreateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskCreateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&const DeepCollectionEquality().equals(other._invitedEmails, _invitedEmails)&&(identical(other.sendInvitesImmediately, sendInvitesImmediately) || other.sendInvitesImmediately == sendInvitesImmediately)&&(identical(other.allowedDomain, allowedDomain) || other.allowedDomain == allowedDomain)&&(identical(other.isDomainValid, isDomainValid) || other.isDomainValid == isDomainValid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,notes,deadLine,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(_subtasks),const DeepCollectionEquality().hash(_invitedEmails),sendInvitesImmediately,allowedDomain,isDomainValid);

@override
String toString() {
  return 'TaskCreateModel(title: $title, notes: $notes, deadLine: $deadLine, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks, invitedEmails: $invitedEmails, sendInvitesImmediately: $sendInvitesImmediately, allowedDomain: $allowedDomain, isDomainValid: $isDomainValid)';
}


}

/// @nodoc
abstract mixin class _$TaskCreateModelCopyWith<$Res> implements $TaskCreateModelCopyWith<$Res> {
  factory _$TaskCreateModelCopyWith(_TaskCreateModel value, $Res Function(_TaskCreateModel) _then) = __$TaskCreateModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String? notes, DateTime deadLine, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskTemplateCreateModel> subtasks, List<String> invitedEmails, bool sendInvitesImmediately, String? allowedDomain,@JsonKey(includeToJson: false) bool? isDomainValid
});




}
/// @nodoc
class __$TaskCreateModelCopyWithImpl<$Res>
    implements _$TaskCreateModelCopyWith<$Res> {
  __$TaskCreateModelCopyWithImpl(this._self, this._then);

  final _TaskCreateModel _self;
  final $Res Function(_TaskCreateModel) _then;

/// Create a copy of TaskCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? notes = freezed,Object? deadLine = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,Object? invitedEmails = null,Object? sendInvitesImmediately = null,Object? allowedDomain = freezed,Object? isDomainValid = freezed,}) {
  return _then(_TaskCreateModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateCreateModel>,invitedEmails: null == invitedEmails ? _self._invitedEmails : invitedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,sendInvitesImmediately: null == sendInvitesImmediately ? _self.sendInvitesImmediately : sendInvitesImmediately // ignore: cast_nullable_to_non_nullable
as bool,allowedDomain: freezed == allowedDomain ? _self.allowedDomain : allowedDomain // ignore: cast_nullable_to_non_nullable
as String?,isDomainValid: freezed == isDomainValid ? _self.isDomainValid : isDomainValid // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
