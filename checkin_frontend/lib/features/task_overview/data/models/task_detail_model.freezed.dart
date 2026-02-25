// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskDetailModel {

// --- Polia z List Modelu ---
 String get id; String get title; String? get notes; String get hash; DateTime get createdAt; DateTime get deadLine; String get createdById; TaskState get state; SubtaskMode get subtaskMode; bool get requiresAuthenticationToComplete; List<SubtaskTemplateListModel> get subtasks;
/// Create a copy of TaskDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailModelCopyWith<TaskDetailModel> get copyWith => _$TaskDetailModelCopyWithImpl<TaskDetailModel>(this as TaskDetailModel, _$identity);

  /// Serializes this TaskDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.state, state) || other.state == state)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other.subtasks, subtasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,hash,createdAt,deadLine,createdById,state,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(subtasks));

@override
String toString() {
  return 'TaskDetailModel(id: $id, title: $title, notes: $notes, hash: $hash, createdAt: $createdAt, deadLine: $deadLine, createdById: $createdById, state: $state, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks)';
}


}

/// @nodoc
abstract mixin class $TaskDetailModelCopyWith<$Res>  {
  factory $TaskDetailModelCopyWith(TaskDetailModel value, $Res Function(TaskDetailModel) _then) = _$TaskDetailModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? notes, String hash, DateTime createdAt, DateTime deadLine, String createdById, TaskState state, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskTemplateListModel> subtasks
});




}
/// @nodoc
class _$TaskDetailModelCopyWithImpl<$Res>
    implements $TaskDetailModelCopyWith<$Res> {
  _$TaskDetailModelCopyWithImpl(this._self, this._then);

  final TaskDetailModel _self;
  final $Res Function(TaskDetailModel) _then;

/// Create a copy of TaskDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? hash = null,Object? createdAt = null,Object? deadLine = null,Object? createdById = null,Object? state = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TaskState,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateListModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskDetailModel].
extension TaskDetailModelPatterns on TaskDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateListModel> subtasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateListModel> subtasks)  $default,) {final _that = this;
switch (_that) {
case _TaskDetailModel():
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskState state,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete,  List<SubtaskTemplateListModel> subtasks)?  $default,) {final _that = this;
switch (_that) {
case _TaskDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.state,_that.subtaskMode,_that.requiresAuthenticationToComplete,_that.subtasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskDetailModel implements TaskDetailModel {
  const _TaskDetailModel({required this.id, required this.title, this.notes, required this.hash, required this.createdAt, required this.deadLine, required this.createdById, required this.state, required this.subtaskMode, this.requiresAuthenticationToComplete = true, final  List<SubtaskTemplateListModel> subtasks = const []}): _subtasks = subtasks;
  factory _TaskDetailModel.fromJson(Map<String, dynamic> json) => _$TaskDetailModelFromJson(json);

// --- Polia z List Modelu ---
@override final  String id;
@override final  String title;
@override final  String? notes;
@override final  String hash;
@override final  DateTime createdAt;
@override final  DateTime deadLine;
@override final  String createdById;
@override final  TaskState state;
@override final  SubtaskMode subtaskMode;
@override@JsonKey() final  bool requiresAuthenticationToComplete;
 final  List<SubtaskTemplateListModel> _subtasks;
@override@JsonKey() List<SubtaskTemplateListModel> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}


/// Create a copy of TaskDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDetailModelCopyWith<_TaskDetailModel> get copyWith => __$TaskDetailModelCopyWithImpl<_TaskDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.state, state) || other.state == state)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,hash,createdAt,deadLine,createdById,state,subtaskMode,requiresAuthenticationToComplete,const DeepCollectionEquality().hash(_subtasks));

@override
String toString() {
  return 'TaskDetailModel(id: $id, title: $title, notes: $notes, hash: $hash, createdAt: $createdAt, deadLine: $deadLine, createdById: $createdById, state: $state, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete, subtasks: $subtasks)';
}


}

/// @nodoc
abstract mixin class _$TaskDetailModelCopyWith<$Res> implements $TaskDetailModelCopyWith<$Res> {
  factory _$TaskDetailModelCopyWith(_TaskDetailModel value, $Res Function(_TaskDetailModel) _then) = __$TaskDetailModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? notes, String hash, DateTime createdAt, DateTime deadLine, String createdById, TaskState state, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete, List<SubtaskTemplateListModel> subtasks
});




}
/// @nodoc
class __$TaskDetailModelCopyWithImpl<$Res>
    implements _$TaskDetailModelCopyWith<$Res> {
  __$TaskDetailModelCopyWithImpl(this._self, this._then);

  final _TaskDetailModel _self;
  final $Res Function(_TaskDetailModel) _then;

/// Create a copy of TaskDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? hash = null,Object? createdAt = null,Object? deadLine = null,Object? createdById = null,Object? state = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,Object? subtasks = null,}) {
  return _then(_TaskDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TaskState,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateListModel>,
  ));
}


}

// dart format on
