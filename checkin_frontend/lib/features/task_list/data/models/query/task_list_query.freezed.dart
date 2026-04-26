// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_list_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskListQuery {

 int get pageNumber; int get pageSize; String get sortBy; bool get sortDesc; String? get nameContains; TaskState? get status; DateTime? get deadLineBefore; DateTime? get deadLineAfter; SubtaskMode? get mode; bool? get requiresAuth; bool? get onlyOverdue; bool? get onlyActive;
/// Create a copy of TaskListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskListQueryCopyWith<TaskListQuery> get copyWith => _$TaskListQueryCopyWithImpl<TaskListQuery>(this as TaskListQuery, _$identity);

  /// Serializes this TaskListQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskListQuery&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.nameContains, nameContains) || other.nameContains == nameContains)&&(identical(other.status, status) || other.status == status)&&(identical(other.deadLineBefore, deadLineBefore) || other.deadLineBefore == deadLineBefore)&&(identical(other.deadLineAfter, deadLineAfter) || other.deadLineAfter == deadLineAfter)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.requiresAuth, requiresAuth) || other.requiresAuth == requiresAuth)&&(identical(other.onlyOverdue, onlyOverdue) || other.onlyOverdue == onlyOverdue)&&(identical(other.onlyActive, onlyActive) || other.onlyActive == onlyActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pageNumber,pageSize,sortBy,sortDesc,nameContains,status,deadLineBefore,deadLineAfter,mode,requiresAuth,onlyOverdue,onlyActive);

@override
String toString() {
  return 'TaskListQuery(pageNumber: $pageNumber, pageSize: $pageSize, sortBy: $sortBy, sortDesc: $sortDesc, nameContains: $nameContains, status: $status, deadLineBefore: $deadLineBefore, deadLineAfter: $deadLineAfter, mode: $mode, requiresAuth: $requiresAuth, onlyOverdue: $onlyOverdue, onlyActive: $onlyActive)';
}


}

/// @nodoc
abstract mixin class $TaskListQueryCopyWith<$Res>  {
  factory $TaskListQueryCopyWith(TaskListQuery value, $Res Function(TaskListQuery) _then) = _$TaskListQueryCopyWithImpl;
@useResult
$Res call({
 int pageNumber, int pageSize, String sortBy, bool sortDesc, String? nameContains, TaskState? status, DateTime? deadLineBefore, DateTime? deadLineAfter, SubtaskMode? mode, bool? requiresAuth, bool? onlyOverdue, bool? onlyActive
});




}
/// @nodoc
class _$TaskListQueryCopyWithImpl<$Res>
    implements $TaskListQueryCopyWith<$Res> {
  _$TaskListQueryCopyWithImpl(this._self, this._then);

  final TaskListQuery _self;
  final $Res Function(TaskListQuery) _then;

/// Create a copy of TaskListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageNumber = null,Object? pageSize = null,Object? sortBy = null,Object? sortDesc = null,Object? nameContains = freezed,Object? status = freezed,Object? deadLineBefore = freezed,Object? deadLineAfter = freezed,Object? mode = freezed,Object? requiresAuth = freezed,Object? onlyOverdue = freezed,Object? onlyActive = freezed,}) {
  return _then(_self.copyWith(
pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,nameContains: freezed == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskState?,deadLineBefore: freezed == deadLineBefore ? _self.deadLineBefore : deadLineBefore // ignore: cast_nullable_to_non_nullable
as DateTime?,deadLineAfter: freezed == deadLineAfter ? _self.deadLineAfter : deadLineAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SubtaskMode?,requiresAuth: freezed == requiresAuth ? _self.requiresAuth : requiresAuth // ignore: cast_nullable_to_non_nullable
as bool?,onlyOverdue: freezed == onlyOverdue ? _self.onlyOverdue : onlyOverdue // ignore: cast_nullable_to_non_nullable
as bool?,onlyActive: freezed == onlyActive ? _self.onlyActive : onlyActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskListQuery].
extension TaskListQueryPatterns on TaskListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskListQuery value)  $default,){
final _that = this;
switch (_that) {
case _TaskListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _TaskListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageNumber,  int pageSize,  String sortBy,  bool sortDesc,  String? nameContains,  TaskState? status,  DateTime? deadLineBefore,  DateTime? deadLineAfter,  SubtaskMode? mode,  bool? requiresAuth,  bool? onlyOverdue,  bool? onlyActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskListQuery() when $default != null:
return $default(_that.pageNumber,_that.pageSize,_that.sortBy,_that.sortDesc,_that.nameContains,_that.status,_that.deadLineBefore,_that.deadLineAfter,_that.mode,_that.requiresAuth,_that.onlyOverdue,_that.onlyActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageNumber,  int pageSize,  String sortBy,  bool sortDesc,  String? nameContains,  TaskState? status,  DateTime? deadLineBefore,  DateTime? deadLineAfter,  SubtaskMode? mode,  bool? requiresAuth,  bool? onlyOverdue,  bool? onlyActive)  $default,) {final _that = this;
switch (_that) {
case _TaskListQuery():
return $default(_that.pageNumber,_that.pageSize,_that.sortBy,_that.sortDesc,_that.nameContains,_that.status,_that.deadLineBefore,_that.deadLineAfter,_that.mode,_that.requiresAuth,_that.onlyOverdue,_that.onlyActive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageNumber,  int pageSize,  String sortBy,  bool sortDesc,  String? nameContains,  TaskState? status,  DateTime? deadLineBefore,  DateTime? deadLineAfter,  SubtaskMode? mode,  bool? requiresAuth,  bool? onlyOverdue,  bool? onlyActive)?  $default,) {final _that = this;
switch (_that) {
case _TaskListQuery() when $default != null:
return $default(_that.pageNumber,_that.pageSize,_that.sortBy,_that.sortDesc,_that.nameContains,_that.status,_that.deadLineBefore,_that.deadLineAfter,_that.mode,_that.requiresAuth,_that.onlyOverdue,_that.onlyActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskListQuery implements TaskListQuery {
  const _TaskListQuery({this.pageNumber = 1, this.pageSize = 12, this.sortBy = "createdat", this.sortDesc = true, this.nameContains, this.status, this.deadLineBefore, this.deadLineAfter, this.mode, this.requiresAuth, this.onlyOverdue, this.onlyActive});
  factory _TaskListQuery.fromJson(Map<String, dynamic> json) => _$TaskListQueryFromJson(json);

@override@JsonKey() final  int pageNumber;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortDesc;
@override final  String? nameContains;
@override final  TaskState? status;
@override final  DateTime? deadLineBefore;
@override final  DateTime? deadLineAfter;
@override final  SubtaskMode? mode;
@override final  bool? requiresAuth;
@override final  bool? onlyOverdue;
@override final  bool? onlyActive;

/// Create a copy of TaskListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskListQueryCopyWith<_TaskListQuery> get copyWith => __$TaskListQueryCopyWithImpl<_TaskListQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskListQueryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskListQuery&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.nameContains, nameContains) || other.nameContains == nameContains)&&(identical(other.status, status) || other.status == status)&&(identical(other.deadLineBefore, deadLineBefore) || other.deadLineBefore == deadLineBefore)&&(identical(other.deadLineAfter, deadLineAfter) || other.deadLineAfter == deadLineAfter)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.requiresAuth, requiresAuth) || other.requiresAuth == requiresAuth)&&(identical(other.onlyOverdue, onlyOverdue) || other.onlyOverdue == onlyOverdue)&&(identical(other.onlyActive, onlyActive) || other.onlyActive == onlyActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pageNumber,pageSize,sortBy,sortDesc,nameContains,status,deadLineBefore,deadLineAfter,mode,requiresAuth,onlyOverdue,onlyActive);

@override
String toString() {
  return 'TaskListQuery(pageNumber: $pageNumber, pageSize: $pageSize, sortBy: $sortBy, sortDesc: $sortDesc, nameContains: $nameContains, status: $status, deadLineBefore: $deadLineBefore, deadLineAfter: $deadLineAfter, mode: $mode, requiresAuth: $requiresAuth, onlyOverdue: $onlyOverdue, onlyActive: $onlyActive)';
}


}

/// @nodoc
abstract mixin class _$TaskListQueryCopyWith<$Res> implements $TaskListQueryCopyWith<$Res> {
  factory _$TaskListQueryCopyWith(_TaskListQuery value, $Res Function(_TaskListQuery) _then) = __$TaskListQueryCopyWithImpl;
@override @useResult
$Res call({
 int pageNumber, int pageSize, String sortBy, bool sortDesc, String? nameContains, TaskState? status, DateTime? deadLineBefore, DateTime? deadLineAfter, SubtaskMode? mode, bool? requiresAuth, bool? onlyOverdue, bool? onlyActive
});




}
/// @nodoc
class __$TaskListQueryCopyWithImpl<$Res>
    implements _$TaskListQueryCopyWith<$Res> {
  __$TaskListQueryCopyWithImpl(this._self, this._then);

  final _TaskListQuery _self;
  final $Res Function(_TaskListQuery) _then;

/// Create a copy of TaskListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageNumber = null,Object? pageSize = null,Object? sortBy = null,Object? sortDesc = null,Object? nameContains = freezed,Object? status = freezed,Object? deadLineBefore = freezed,Object? deadLineAfter = freezed,Object? mode = freezed,Object? requiresAuth = freezed,Object? onlyOverdue = freezed,Object? onlyActive = freezed,}) {
  return _then(_TaskListQuery(
pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,nameContains: freezed == nameContains ? _self.nameContains : nameContains // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskState?,deadLineBefore: freezed == deadLineBefore ? _self.deadLineBefore : deadLineBefore // ignore: cast_nullable_to_non_nullable
as DateTime?,deadLineAfter: freezed == deadLineAfter ? _self.deadLineAfter : deadLineAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SubtaskMode?,requiresAuth: freezed == requiresAuth ? _self.requiresAuth : requiresAuth // ignore: cast_nullable_to_non_nullable
as bool?,onlyOverdue: freezed == onlyOverdue ? _self.onlyOverdue : onlyOverdue // ignore: cast_nullable_to_non_nullable
as bool?,onlyActive: freezed == onlyActive ? _self.onlyActive : onlyActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
