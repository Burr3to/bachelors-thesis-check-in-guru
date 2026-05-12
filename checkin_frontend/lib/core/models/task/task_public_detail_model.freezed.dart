// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_public_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskPublicDetailModel {

// Zmenené na nullable, pretože pri Forbidden/Unauthorized stave id a hash nemusia prísť
 String? get id; String? get hash; String get title; String? get notes; DateTime? get deadLine; TaskState get state; SubtaskMode get subtaskMode; bool get requiresAuthenticationToComplete; List<SubtaskCombinedListModel> get subtasks; String? get allowedDomain;// --- NOVÉ POLIA PRE SOFT-ERROR HANDLING ---
 bool get isForbidden; String? get forbiddenMessage;
/// Create a copy of TaskPublicDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskPublicDetailModelCopyWith<TaskPublicDetailModel> get copyWith => _$TaskPublicDetailModelCopyWithImpl<TaskPublicDetailModel>(this as TaskPublicDetailModel, _$identity);

  /// Serializes this TaskPublicDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskPublicDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.state, state) || other.state == state)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&(identical(other.allowedDomain, allowedDomain) || other.allowedDomain == allowedDomain)&&(identical(other.isForbidden, isForbidden) || other.isForbidden == isForbidden)&&(identical(other.forbiddenMessage, forbiddenMessage) || other.forbiddenMessage == forbiddenMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hash,title,notes,deadLine,state,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(subtasks),allowedDomain,isForbidden,forbiddenMessage);

@override
String toString() {
  return 'TaskPublicDetailModel(id: $id, hash: $hash, title: $title, notes: $notes, deadLine: $deadLine, state: $state, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks, allowedDomain: $allowedDomain, isForbidden: $isForbidden, forbiddenMessage: $forbiddenMessage)';
}


}

/// @nodoc
abstract mixin class $TaskPublicDetailModelCopyWith<$Res>  {
  factory $TaskPublicDetailModelCopyWith(TaskPublicDetailModel value, $Res Function(TaskPublicDetailModel) _then) = _$TaskPublicDetailModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? hash, String title, String? notes, DateTime? deadLine, TaskState state, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskCombinedListModel> subtasks, String? allowedDomain, bool isForbidden, String? forbiddenMessage
});




}
/// @nodoc
class _$TaskPublicDetailModelCopyWithImpl<$Res>
    implements $TaskPublicDetailModelCopyWith<$Res> {
  _$TaskPublicDetailModelCopyWithImpl(this._self, this._then);

  final TaskPublicDetailModel _self;
  final $Res Function(TaskPublicDetailModel) _then;

/// Create a copy of TaskPublicDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? hash = freezed,Object? title = null,Object? notes = freezed,Object? deadLine = freezed,Object? state = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,Object? allowedDomain = freezed,Object? isForbidden = null,Object? forbiddenMessage = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: freezed == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TaskState,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskCombinedListModel>,allowedDomain: freezed == allowedDomain ? _self.allowedDomain : allowedDomain // ignore: cast_nullable_to_non_nullable
as String?,isForbidden: null == isForbidden ? _self.isForbidden : isForbidden // ignore: cast_nullable_to_non_nullable
as bool,forbiddenMessage: freezed == forbiddenMessage ? _self.forbiddenMessage : forbiddenMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskPublicDetailModel].
extension TaskPublicDetailModelPatterns on TaskPublicDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskPublicDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskPublicDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskPublicDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskPublicDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskPublicDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskPublicDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? hash,  String title,  String? notes,  DateTime? deadLine,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskCombinedListModel> subtasks,  String? allowedDomain,  bool isForbidden,  String? forbiddenMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskPublicDetailModel() when $default != null:
return $default(_that.id,_that.hash,_that.title,_that.notes,_that.deadLine,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.allowedDomain,_that.isForbidden,_that.forbiddenMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? hash,  String title,  String? notes,  DateTime? deadLine,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskCombinedListModel> subtasks,  String? allowedDomain,  bool isForbidden,  String? forbiddenMessage)  $default,) {final _that = this;
switch (_that) {
case _TaskPublicDetailModel():
return $default(_that.id,_that.hash,_that.title,_that.notes,_that.deadLine,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.allowedDomain,_that.isForbidden,_that.forbiddenMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? hash,  String title,  String? notes,  DateTime? deadLine,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskCombinedListModel> subtasks,  String? allowedDomain,  bool isForbidden,  String? forbiddenMessage)?  $default,) {final _that = this;
switch (_that) {
case _TaskPublicDetailModel() when $default != null:
return $default(_that.id,_that.hash,_that.title,_that.notes,_that.deadLine,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks,_that.allowedDomain,_that.isForbidden,_that.forbiddenMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskPublicDetailModel implements TaskPublicDetailModel {
  const _TaskPublicDetailModel({this.id, this.hash, this.title = '', this.notes, this.deadLine, this.state = TaskState.inProgress, this.subtaskMode = SubtaskMode.individual, this.requiresAuthenticationToComplete = false, final  List<SubtaskCombinedListModel> subtasks = const [], this.allowedDomain, this.isForbidden = false, this.forbiddenMessage}): _subtasks = subtasks;
  factory _TaskPublicDetailModel.fromJson(Map<String, dynamic> json) => _$TaskPublicDetailModelFromJson(json);

// Zmenené na nullable, pretože pri Forbidden/Unauthorized stave id a hash nemusia prísť
@override final  String? id;
@override final  String? hash;
@override@JsonKey() final  String title;
@override final  String? notes;
@override final  DateTime? deadLine;
@override@JsonKey() final  TaskState state;
@override@JsonKey() final  SubtaskMode subtaskMode;
@override@JsonKey() final  bool requiresAuthenticationToComplete;
 final  List<SubtaskCombinedListModel> _subtasks;
@override@JsonKey() List<SubtaskCombinedListModel> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

@override final  String? allowedDomain;
// --- NOVÉ POLIA PRE SOFT-ERROR HANDLING ---
@override@JsonKey() final  bool isForbidden;
@override final  String? forbiddenMessage;

/// Create a copy of TaskPublicDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskPublicDetailModelCopyWith<_TaskPublicDetailModel> get copyWith => __$TaskPublicDetailModelCopyWithImpl<_TaskPublicDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskPublicDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskPublicDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.state, state) || other.state == state)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&(identical(other.allowedDomain, allowedDomain) || other.allowedDomain == allowedDomain)&&(identical(other.isForbidden, isForbidden) || other.isForbidden == isForbidden)&&(identical(other.forbiddenMessage, forbiddenMessage) || other.forbiddenMessage == forbiddenMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hash,title,notes,deadLine,state,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(_subtasks),allowedDomain,isForbidden,forbiddenMessage);

@override
String toString() {
  return 'TaskPublicDetailModel(id: $id, hash: $hash, title: $title, notes: $notes, deadLine: $deadLine, state: $state, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks, allowedDomain: $allowedDomain, isForbidden: $isForbidden, forbiddenMessage: $forbiddenMessage)';
}


}

/// @nodoc
abstract mixin class _$TaskPublicDetailModelCopyWith<$Res> implements $TaskPublicDetailModelCopyWith<$Res> {
  factory _$TaskPublicDetailModelCopyWith(_TaskPublicDetailModel value, $Res Function(_TaskPublicDetailModel) _then) = __$TaskPublicDetailModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? hash, String title, String? notes, DateTime? deadLine, TaskState state, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskCombinedListModel> subtasks, String? allowedDomain, bool isForbidden, String? forbiddenMessage
});




}
/// @nodoc
class __$TaskPublicDetailModelCopyWithImpl<$Res>
    implements _$TaskPublicDetailModelCopyWith<$Res> {
  __$TaskPublicDetailModelCopyWithImpl(this._self, this._then);

  final _TaskPublicDetailModel _self;
  final $Res Function(_TaskPublicDetailModel) _then;

/// Create a copy of TaskPublicDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? hash = freezed,Object? title = null,Object? notes = freezed,Object? deadLine = freezed,Object? state = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,Object? allowedDomain = freezed,Object? isForbidden = null,Object? forbiddenMessage = freezed,}) {
  return _then(_TaskPublicDetailModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: freezed == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TaskState,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskCombinedListModel>,allowedDomain: freezed == allowedDomain ? _self.allowedDomain : allowedDomain // ignore: cast_nullable_to_non_nullable
as String?,isForbidden: null == isForbidden ? _self.isForbidden : isForbidden // ignore: cast_nullable_to_non_nullable
as bool,forbiddenMessage: freezed == forbiddenMessage ? _self.forbiddenMessage : forbiddenMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
