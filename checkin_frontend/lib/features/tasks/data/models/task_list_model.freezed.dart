// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskListModel {

 String get id; String get title; String? get notes;// Pridané
 String get hash; DateTime get createdAt; DateTime get deadLine; String get createdById;// Nové polia
 TaskStatus get status;// Teraz už máme enum
 SubtaskMode get subtaskMode; bool get requiresAuthenticationToComplete;
/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskListModelCopyWith<TaskListModel> get copyWith => _$TaskListModelCopyWithImpl<TaskListModel>(this as TaskListModel, _$identity);

  /// Serializes this TaskListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.status, status) || other.status == status)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,hash,createdAt,deadLine,createdById,status,subtaskMode,requiresAuthenticationToComplete);

@override
String toString() {
  return 'TaskListModel(id: $id, title: $title, notes: $notes, hash: $hash, createdAt: $createdAt, deadLine: $deadLine, createdById: $createdById, status: $status, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete)';
}


}

/// @nodoc
abstract mixin class $TaskListModelCopyWith<$Res>  {
  factory $TaskListModelCopyWith(TaskListModel value, $Res Function(TaskListModel) _then) = _$TaskListModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? notes, String hash, DateTime createdAt, DateTime deadLine, String createdById, TaskStatus status, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete
});




}
/// @nodoc
class _$TaskListModelCopyWithImpl<$Res>
    implements $TaskListModelCopyWith<$Res> {
  _$TaskListModelCopyWithImpl(this._self, this._then);

  final TaskListModel _self;
  final $Res Function(TaskListModel) _then;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? hash = null,Object? createdAt = null,Object? deadLine = null,Object? createdById = null,Object? status = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskListModel].
extension TaskListModelPatterns on TaskListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskListModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskListModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskStatus status,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.status,_that.subtaskMode,_that.requiresAuthenticationToComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskStatus status,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete)  $default,) {final _that = this;
switch (_that) {
case _TaskListModel():
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.status,_that.subtaskMode,_that.requiresAuthenticationToComplete);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? notes,  String hash,  DateTime createdAt,  DateTime deadLine,  String createdById,  TaskStatus status,  SubtaskMode subtaskMode,  bool requiresAuthenticationToComplete)?  $default,) {final _that = this;
switch (_that) {
case _TaskListModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.hash,_that.createdAt,_that.deadLine,_that.createdById,_that.status,_that.subtaskMode,_that.requiresAuthenticationToComplete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskListModel implements TaskListModel {
  const _TaskListModel({required this.id, required this.title, this.notes, required this.hash, required this.createdAt, required this.deadLine, required this.createdById, required this.status, required this.subtaskMode, this.requiresAuthenticationToComplete = true});
  factory _TaskListModel.fromJson(Map<String, dynamic> json) => _$TaskListModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? notes;
// Pridané
@override final  String hash;
@override final  DateTime createdAt;
@override final  DateTime deadLine;
@override final  String createdById;
// Nové polia
@override final  TaskStatus status;
// Teraz už máme enum
@override final  SubtaskMode subtaskMode;
@override@JsonKey() final  bool requiresAuthenticationToComplete;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskListModelCopyWith<_TaskListModel> get copyWith => __$TaskListModelCopyWithImpl<_TaskListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&(identical(other.createdById, createdById) || other.createdById == createdById)&&(identical(other.status, status) || other.status == status)&&(identical(other.subtaskMode, subtaskMode) || other.subtaskMode == subtaskMode)&&(identical(other.requiresAuthenticationToComplete, requiresAuthenticationToComplete) || other.requiresAuthenticationToComplete == requiresAuthenticationToComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,hash,createdAt,deadLine,createdById,status,subtaskMode,requiresAuthenticationToComplete);

@override
String toString() {
  return 'TaskListModel(id: $id, title: $title, notes: $notes, hash: $hash, createdAt: $createdAt, deadLine: $deadLine, createdById: $createdById, status: $status, subtaskMode: $subtaskMode, requiresAuthenticationToComplete: $requiresAuthenticationToComplete)';
}


}

/// @nodoc
abstract mixin class _$TaskListModelCopyWith<$Res> implements $TaskListModelCopyWith<$Res> {
  factory _$TaskListModelCopyWith(_TaskListModel value, $Res Function(_TaskListModel) _then) = __$TaskListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? notes, String hash, DateTime createdAt, DateTime deadLine, String createdById, TaskStatus status, SubtaskMode subtaskMode, bool requiresAuthenticationToComplete
});




}
/// @nodoc
class __$TaskListModelCopyWithImpl<$Res>
    implements _$TaskListModelCopyWith<$Res> {
  __$TaskListModelCopyWithImpl(this._self, this._then);

  final _TaskListModel _self;
  final $Res Function(_TaskListModel) _then;

/// Create a copy of TaskListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? hash = null,Object? createdAt = null,Object? deadLine = null,Object? createdById = null,Object? status = null,Object? subtaskMode = null,Object? requiresAuthenticationToComplete = null,}) {
  return _then(_TaskListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: null == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,subtaskMode: null == subtaskMode ? _self.subtaskMode : subtaskMode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,requiresAuthenticationToComplete: null == requiresAuthenticationToComplete ? _self.requiresAuthenticationToComplete : requiresAuthenticationToComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
