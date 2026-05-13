// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_summary_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskSummaryStats {

 String get taskId; SubtaskMode get mode; double get globalProgress; int get totalRespondents; int get completedFull; int get inProgress; int get notStarted; int get totalSubtasks; int get completedSubtasks;// --- NOVÉ POLIA PRE FARBY ---
 int get completedOnTime;// Pre ZELENÚ farbu
 int get issuesCount;
/// Create a copy of TaskSummaryStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskSummaryStatsCopyWith<TaskSummaryStats> get copyWith => _$TaskSummaryStatsCopyWithImpl<TaskSummaryStats>(this as TaskSummaryStats, _$identity);

  /// Serializes this TaskSummaryStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskSummaryStats&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.globalProgress, globalProgress) || other.globalProgress == globalProgress)&&(identical(other.totalRespondents, totalRespondents) || other.totalRespondents == totalRespondents)&&(identical(other.completedFull, completedFull) || other.completedFull == completedFull)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.totalSubtasks, totalSubtasks) || other.totalSubtasks == totalSubtasks)&&(identical(other.completedSubtasks, completedSubtasks) || other.completedSubtasks == completedSubtasks)&&(identical(other.completedOnTime, completedOnTime) || other.completedOnTime == completedOnTime)&&(identical(other.issuesCount, issuesCount) || other.issuesCount == issuesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,mode,globalProgress,totalRespondents,completedFull,inProgress,notStarted,totalSubtasks,completedSubtasks,completedOnTime,issuesCount);

@override
String toString() {
  return 'TaskSummaryStats(taskId: $taskId, mode: $mode, globalProgress: $globalProgress, totalRespondents: $totalRespondents, completedFull: $completedFull, inProgress: $inProgress, notStarted: $notStarted, totalSubtasks: $totalSubtasks, completedSubtasks: $completedSubtasks, completedOnTime: $completedOnTime, issuesCount: $issuesCount)';
}


}

/// @nodoc
abstract mixin class $TaskSummaryStatsCopyWith<$Res>  {
  factory $TaskSummaryStatsCopyWith(TaskSummaryStats value, $Res Function(TaskSummaryStats) _then) = _$TaskSummaryStatsCopyWithImpl;
@useResult
$Res call({
 String taskId, SubtaskMode mode, double globalProgress, int totalRespondents, int completedFull, int inProgress, int notStarted, int totalSubtasks, int completedSubtasks, int completedOnTime, int issuesCount
});




}
/// @nodoc
class _$TaskSummaryStatsCopyWithImpl<$Res>
    implements $TaskSummaryStatsCopyWith<$Res> {
  _$TaskSummaryStatsCopyWithImpl(this._self, this._then);

  final TaskSummaryStats _self;
  final $Res Function(TaskSummaryStats) _then;

/// Create a copy of TaskSummaryStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? mode = null,Object? globalProgress = null,Object? totalRespondents = null,Object? completedFull = null,Object? inProgress = null,Object? notStarted = null,Object? totalSubtasks = null,Object? completedSubtasks = null,Object? completedOnTime = null,Object? issuesCount = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,globalProgress: null == globalProgress ? _self.globalProgress : globalProgress // ignore: cast_nullable_to_non_nullable
as double,totalRespondents: null == totalRespondents ? _self.totalRespondents : totalRespondents // ignore: cast_nullable_to_non_nullable
as int,completedFull: null == completedFull ? _self.completedFull : completedFull // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,totalSubtasks: null == totalSubtasks ? _self.totalSubtasks : totalSubtasks // ignore: cast_nullable_to_non_nullable
as int,completedSubtasks: null == completedSubtasks ? _self.completedSubtasks : completedSubtasks // ignore: cast_nullable_to_non_nullable
as int,completedOnTime: null == completedOnTime ? _self.completedOnTime : completedOnTime // ignore: cast_nullable_to_non_nullable
as int,issuesCount: null == issuesCount ? _self.issuesCount : issuesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskSummaryStats].
extension TaskSummaryStatsPatterns on TaskSummaryStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskSummaryStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskSummaryStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskSummaryStats value)  $default,){
final _that = this;
switch (_that) {
case _TaskSummaryStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskSummaryStats value)?  $default,){
final _that = this;
switch (_that) {
case _TaskSummaryStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  SubtaskMode mode,  double globalProgress,  int totalRespondents,  int completedFull,  int inProgress,  int notStarted,  int totalSubtasks,  int completedSubtasks,  int completedOnTime,  int issuesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskSummaryStats() when $default != null:
return $default(_that.taskId,_that.mode,_that.globalProgress,_that.totalRespondents,_that.completedFull,_that.inProgress,_that.notStarted,_that.totalSubtasks,_that.completedSubtasks,_that.completedOnTime,_that.issuesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  SubtaskMode mode,  double globalProgress,  int totalRespondents,  int completedFull,  int inProgress,  int notStarted,  int totalSubtasks,  int completedSubtasks,  int completedOnTime,  int issuesCount)  $default,) {final _that = this;
switch (_that) {
case _TaskSummaryStats():
return $default(_that.taskId,_that.mode,_that.globalProgress,_that.totalRespondents,_that.completedFull,_that.inProgress,_that.notStarted,_that.totalSubtasks,_that.completedSubtasks,_that.completedOnTime,_that.issuesCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  SubtaskMode mode,  double globalProgress,  int totalRespondents,  int completedFull,  int inProgress,  int notStarted,  int totalSubtasks,  int completedSubtasks,  int completedOnTime,  int issuesCount)?  $default,) {final _that = this;
switch (_that) {
case _TaskSummaryStats() when $default != null:
return $default(_that.taskId,_that.mode,_that.globalProgress,_that.totalRespondents,_that.completedFull,_that.inProgress,_that.notStarted,_that.totalSubtasks,_that.completedSubtasks,_that.completedOnTime,_that.issuesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskSummaryStats implements TaskSummaryStats {
  const _TaskSummaryStats({required this.taskId, required this.mode, required this.globalProgress, this.totalRespondents = 0, this.completedFull = 0, this.inProgress = 0, this.notStarted = 0, this.totalSubtasks = 0, this.completedSubtasks = 0, this.completedOnTime = 0, this.issuesCount = 0});
  factory _TaskSummaryStats.fromJson(Map<String, dynamic> json) => _$TaskSummaryStatsFromJson(json);

@override final  String taskId;
@override final  SubtaskMode mode;
@override final  double globalProgress;
@override@JsonKey() final  int totalRespondents;
@override@JsonKey() final  int completedFull;
@override@JsonKey() final  int inProgress;
@override@JsonKey() final  int notStarted;
@override@JsonKey() final  int totalSubtasks;
@override@JsonKey() final  int completedSubtasks;
// --- NOVÉ POLIA PRE FARBY ---
@override@JsonKey() final  int completedOnTime;
// Pre ZELENÚ farbu
@override@JsonKey() final  int issuesCount;

/// Create a copy of TaskSummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskSummaryStatsCopyWith<_TaskSummaryStats> get copyWith => __$TaskSummaryStatsCopyWithImpl<_TaskSummaryStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskSummaryStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskSummaryStats&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.globalProgress, globalProgress) || other.globalProgress == globalProgress)&&(identical(other.totalRespondents, totalRespondents) || other.totalRespondents == totalRespondents)&&(identical(other.completedFull, completedFull) || other.completedFull == completedFull)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.notStarted, notStarted) || other.notStarted == notStarted)&&(identical(other.totalSubtasks, totalSubtasks) || other.totalSubtasks == totalSubtasks)&&(identical(other.completedSubtasks, completedSubtasks) || other.completedSubtasks == completedSubtasks)&&(identical(other.completedOnTime, completedOnTime) || other.completedOnTime == completedOnTime)&&(identical(other.issuesCount, issuesCount) || other.issuesCount == issuesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,mode,globalProgress,totalRespondents,completedFull,inProgress,notStarted,totalSubtasks,completedSubtasks,completedOnTime,issuesCount);

@override
String toString() {
  return 'TaskSummaryStats(taskId: $taskId, mode: $mode, globalProgress: $globalProgress, totalRespondents: $totalRespondents, completedFull: $completedFull, inProgress: $inProgress, notStarted: $notStarted, totalSubtasks: $totalSubtasks, completedSubtasks: $completedSubtasks, completedOnTime: $completedOnTime, issuesCount: $issuesCount)';
}


}

/// @nodoc
abstract mixin class _$TaskSummaryStatsCopyWith<$Res> implements $TaskSummaryStatsCopyWith<$Res> {
  factory _$TaskSummaryStatsCopyWith(_TaskSummaryStats value, $Res Function(_TaskSummaryStats) _then) = __$TaskSummaryStatsCopyWithImpl;
@override @useResult
$Res call({
 String taskId, SubtaskMode mode, double globalProgress, int totalRespondents, int completedFull, int inProgress, int notStarted, int totalSubtasks, int completedSubtasks, int completedOnTime, int issuesCount
});




}
/// @nodoc
class __$TaskSummaryStatsCopyWithImpl<$Res>
    implements _$TaskSummaryStatsCopyWith<$Res> {
  __$TaskSummaryStatsCopyWithImpl(this._self, this._then);

  final _TaskSummaryStats _self;
  final $Res Function(_TaskSummaryStats) _then;

/// Create a copy of TaskSummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? mode = null,Object? globalProgress = null,Object? totalRespondents = null,Object? completedFull = null,Object? inProgress = null,Object? notStarted = null,Object? totalSubtasks = null,Object? completedSubtasks = null,Object? completedOnTime = null,Object? issuesCount = null,}) {
  return _then(_TaskSummaryStats(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SubtaskMode,globalProgress: null == globalProgress ? _self.globalProgress : globalProgress // ignore: cast_nullable_to_non_nullable
as double,totalRespondents: null == totalRespondents ? _self.totalRespondents : totalRespondents // ignore: cast_nullable_to_non_nullable
as int,completedFull: null == completedFull ? _self.completedFull : completedFull // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,notStarted: null == notStarted ? _self.notStarted : notStarted // ignore: cast_nullable_to_non_nullable
as int,totalSubtasks: null == totalSubtasks ? _self.totalSubtasks : totalSubtasks // ignore: cast_nullable_to_non_nullable
as int,completedSubtasks: null == completedSubtasks ? _self.completedSubtasks : completedSubtasks // ignore: cast_nullable_to_non_nullable
as int,completedOnTime: null == completedOnTime ? _self.completedOnTime : completedOnTime // ignore: cast_nullable_to_non_nullable
as int,issuesCount: null == issuesCount ? _self.issuesCount : issuesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
