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

 String get title; String? get notes; DateTime get deadLine;
/// Create a copy of TaskCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCreateModelCopyWith<TaskCreateModel> get copyWith => _$TaskCreateModelCopyWithImpl<TaskCreateModel>(this as TaskCreateModel, _$identity);

  /// Serializes this TaskCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,notes,deadLine);

@override
String toString() {
  return 'TaskCreateModel(title: $title, notes: $notes, deadLine: $deadLine)';
}


}

/// @nodoc
abstract mixin class $TaskCreateModelCopyWith<$Res>  {
  factory $TaskCreateModelCopyWith(TaskCreateModel value, $Res Function(TaskCreateModel) _then) = _$TaskCreateModelCopyWithImpl;
@useResult
$Res call({
 String title, String? notes, DateTime deadLine
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
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? notes = freezed,Object? deadLine = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? notes,  DateTime deadLine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
return $default(_that.title,_that.notes,_that.deadLine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? notes,  DateTime deadLine)  $default,) {final _that = this;
switch (_that) {
case _TaskCreateModel():
return $default(_that.title,_that.notes,_that.deadLine);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? notes,  DateTime deadLine)?  $default,) {final _that = this;
switch (_that) {
case _TaskCreateModel() when $default != null:
return $default(_that.title,_that.notes,_that.deadLine);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskCreateModel implements TaskCreateModel {
  const _TaskCreateModel({required this.title, this.notes, required this.deadLine});
  factory _TaskCreateModel.fromJson(Map<String, dynamic> json) => _$TaskCreateModelFromJson(json);

@override final  String title;
@override final  String? notes;
@override final  DateTime deadLine;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deadLine, deadLine) || other.deadLine == deadLine));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,notes,deadLine);

@override
String toString() {
  return 'TaskCreateModel(title: $title, notes: $notes, deadLine: $deadLine)';
}


}

/// @nodoc
abstract mixin class _$TaskCreateModelCopyWith<$Res> implements $TaskCreateModelCopyWith<$Res> {
  factory _$TaskCreateModelCopyWith(_TaskCreateModel value, $Res Function(_TaskCreateModel) _then) = __$TaskCreateModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String? notes, DateTime deadLine
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
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? notes = freezed,Object? deadLine = null,}) {
  return _then(_TaskCreateModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deadLine: null == deadLine ? _self.deadLine : deadLine // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
