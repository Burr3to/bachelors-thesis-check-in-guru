// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_update_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskUpdateModel {

 String get id; String get title; String? get notes; DateTime get deadLine; List<String> get invitedEmails; List<SubtaskTemplateCreateModel> get subtasks;
/// Create a copy of TaskUpdateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskUpdateModelCopyWith<TaskUpdateModel> get copyWith => _$TaskUpdateModelCopyWithImpl<TaskUpdateModel>(this as TaskUpdateModel, _$identity);

  /// Serializes this TaskUpdateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskUpdateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&const DeepCollectionEquality().equals(other.invitedEmails, invitedEmails)&&const DeepCollectionEquality().equals(other.subtasks, subtasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,deadLine,const DeepCollectionEquality().hash(invitedEmails),const DeepCollectionEquality().hash(subtasks));

@override
String toString() {
  return 'TaskUpdateModel(id: $id, title: $title, notes: $notes, deadLine: $deadLine, invitedEmails: $invitedEmails, subtasks: $subtasks)';
}


}

/// @nodoc
abstract mixin class $TaskUpdateModelCopyWith<$Res>  {
  factory $TaskUpdateModelCopyWith(TaskUpdateModel value, $Res Function(TaskUpdateModel) _then) = _$TaskUpdateModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? notes, DateTime deadLine, List<String> invitedEmails, List<SubtaskTemplateCreateModel> subtasks
});




}
/// @nodoc
class _$TaskUpdateModelCopyWithImpl<$Res>
    implements $TaskUpdateModelCopyWith<$Res> {
  _$TaskUpdateModelCopyWithImpl(this._self, this._then);

  final TaskUpdateModel _self;
  final $Res Function(TaskUpdateModel) _then;

/// Create a copy of TaskUpdateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? deadLine = null,Object? invitedEmails = null,Object? subtasks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,invitedEmails: null == invitedEmails ? _self.invitedEmails : invitedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateCreateModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskUpdateModel].
extension TaskUpdateModelPatterns on TaskUpdateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskUpdateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskUpdateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskUpdateModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskUpdateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskUpdateModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskUpdateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  DateTime deadLine,  List<String> invitedEmails,  List<SubtaskTemplateCreateModel> subtasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskUpdateModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.deadLine,_that.invitedEmails,_that.subtasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? notes,  DateTime deadLine,  List<String> invitedEmails,  List<SubtaskTemplateCreateModel> subtasks)  $default,) {final _that = this;
switch (_that) {
case _TaskUpdateModel():
return $default(_that.id,_that.title,_that.notes,_that.deadLine,_that.invitedEmails,_that.subtasks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? notes,  DateTime deadLine,  List<String> invitedEmails,  List<SubtaskTemplateCreateModel> subtasks)?  $default,) {final _that = this;
switch (_that) {
case _TaskUpdateModel() when $default != null:
return $default(_that.id,_that.title,_that.notes,_that.deadLine,_that.invitedEmails,_that.subtasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskUpdateModel implements TaskUpdateModel {
  const _TaskUpdateModel({required this.id, required this.title, this.notes, required this.deadLine, final  List<String> invitedEmails = const [], final  List<SubtaskTemplateCreateModel> subtasks = const []}): _invitedEmails = invitedEmails,_subtasks = subtasks;
  factory _TaskUpdateModel.fromJson(Map<String, dynamic> json) => _$TaskUpdateModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? notes;
@override final  DateTime deadLine;
 final  List<String> _invitedEmails;
@override@JsonKey() List<String> get invitedEmails {
  if (_invitedEmails is EqualUnmodifiableListView) return _invitedEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitedEmails);
}

 final  List<SubtaskTemplateCreateModel> _subtasks;
@override@JsonKey() List<SubtaskTemplateCreateModel> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}


/// Create a copy of TaskUpdateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskUpdateModelCopyWith<_TaskUpdateModel> get copyWith => __$TaskUpdateModelCopyWithImpl<_TaskUpdateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskUpdateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskUpdateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine)&&const DeepCollectionEquality().equals(other._invitedEmails, _invitedEmails)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,notes,deadLine,const DeepCollectionEquality().hash(_invitedEmails),const DeepCollectionEquality().hash(_subtasks));

@override
String toString() {
  return 'TaskUpdateModel(id: $id, title: $title, notes: $notes, deadLine: $deadLine, invitedEmails: $invitedEmails, subtasks: $subtasks)';
}


}

/// @nodoc
abstract mixin class _$TaskUpdateModelCopyWith<$Res> implements $TaskUpdateModelCopyWith<$Res> {
  factory _$TaskUpdateModelCopyWith(_TaskUpdateModel value, $Res Function(_TaskUpdateModel) _then) = __$TaskUpdateModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? notes, DateTime deadLine, List<String> invitedEmails, List<SubtaskTemplateCreateModel> subtasks
});




}
/// @nodoc
class __$TaskUpdateModelCopyWithImpl<$Res>
    implements _$TaskUpdateModelCopyWith<$Res> {
  __$TaskUpdateModelCopyWithImpl(this._self, this._then);

  final _TaskUpdateModel _self;
  final $Res Function(_TaskUpdateModel) _then;

/// Create a copy of TaskUpdateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? notes = freezed,Object? deadLine = null,Object? invitedEmails = null,Object? subtasks = null,}) {
  return _then(_TaskUpdateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,invitedEmails: null == invitedEmails ? _self._invitedEmails : invitedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubtaskTemplateCreateModel>,
  ));
}


}

// dart format on
