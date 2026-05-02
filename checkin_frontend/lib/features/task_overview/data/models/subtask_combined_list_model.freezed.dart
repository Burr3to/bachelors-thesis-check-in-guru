// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_combined_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtaskCombinedListModel {

 String get id;// ID Inštancie
 bool get isCompleted; String get responseGroupId; String? get respondentName; String? get comment; String? get assignedToUserId; String? get completedByUserId; DateTime? get completedAt; String get title; String? get assignedToEmail; DateTime get deadline; DateTime? get createdAt; String? get description;// Popis zo šablóny
 String get templateSubtaskId; bool get isGeneratedFromTask;
/// Create a copy of SubtaskCombinedListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskCombinedListModelCopyWith<SubtaskCombinedListModel> get copyWith => _$SubtaskCombinedListModelCopyWithImpl<SubtaskCombinedListModel>(this as SubtaskCombinedListModel, _$identity);

  /// Serializes this SubtaskCombinedListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskCombinedListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.responseGroupId, responseGroupId) || other.responseGroupId == responseGroupId)&&(identical(other.respondentName, respondentName) || other.respondentName == respondentName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.assignedToEmail, assignedToEmail) || other.assignedToEmail == assignedToEmail)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.isGeneratedFromTask, isGeneratedFromTask) || other.isGeneratedFromTask == isGeneratedFromTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isCompleted,responseGroupId,respondentName,comment,assignedToUserId,completedByUserId,completedAt,title,assignedToEmail,deadline,createdAt,description,templateSubtaskId,isGeneratedFromTask);

@override
String toString() {
  return 'SubtaskCombinedListModel(id: $id, isCompleted: $isCompleted, responseGroupId: $responseGroupId, respondentName: $respondentName, comment: $comment, assignedToUserId: $assignedToUserId, completedByUserId: $completedByUserId, completedAt: $completedAt, title: $title, assignedToEmail: $assignedToEmail, deadline: $deadline, createdAt: $createdAt, description: $description, templateSubtaskId: $templateSubtaskId, isGeneratedFromTask: $isGeneratedFromTask)';
}


}

/// @nodoc
abstract mixin class $SubtaskCombinedListModelCopyWith<$Res>  {
  factory $SubtaskCombinedListModelCopyWith(SubtaskCombinedListModel value, $Res Function(SubtaskCombinedListModel) _then) = _$SubtaskCombinedListModelCopyWithImpl;
@useResult
$Res call({
 String id, bool isCompleted, String responseGroupId, String? respondentName, String? comment, String? assignedToUserId, String? completedByUserId, DateTime? completedAt, String title, String? assignedToEmail, DateTime deadline, DateTime? createdAt, String? description, String templateSubtaskId, bool isGeneratedFromTask
});




}
/// @nodoc
class _$SubtaskCombinedListModelCopyWithImpl<$Res>
    implements $SubtaskCombinedListModelCopyWith<$Res> {
  _$SubtaskCombinedListModelCopyWithImpl(this._self, this._then);

  final SubtaskCombinedListModel _self;
  final $Res Function(SubtaskCombinedListModel) _then;

/// Create a copy of SubtaskCombinedListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isCompleted = null,Object? responseGroupId = null,Object? respondentName = freezed,Object? comment = freezed,Object? assignedToUserId = freezed,Object? completedByUserId = freezed,Object? completedAt = freezed,Object? title = null,Object? assignedToEmail = freezed,Object? deadline = null,Object? createdAt = freezed,Object? description = freezed,Object? templateSubtaskId = null,Object? isGeneratedFromTask = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,responseGroupId: null == responseGroupId ? _self.responseGroupId : responseGroupId // ignore: cast_nullable_to_non_nullable
as String,respondentName: freezed == respondentName ? _self.respondentName : respondentName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,assignedToEmail: freezed == assignedToEmail ? _self.assignedToEmail : assignedToEmail // ignore: cast_nullable_to_non_nullable
as String?,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,isGeneratedFromTask: null == isGeneratedFromTask ? _self.isGeneratedFromTask : isGeneratedFromTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskCombinedListModel].
extension SubtaskCombinedListModelPatterns on SubtaskCombinedListModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskCombinedListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskCombinedListModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskCombinedListModel value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskCombinedListModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskCombinedListModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskCombinedListModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isCompleted,  String responseGroupId,  String? respondentName,  String? comment,  String? assignedToUserId,  String? completedByUserId,  DateTime? completedAt,  String title,  String? assignedToEmail,  DateTime deadline,  DateTime? createdAt,  String? description,  String templateSubtaskId,  bool isGeneratedFromTask)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskCombinedListModel() when $default != null:
return $default(_that.id,_that.isCompleted,_that.responseGroupId,_that.respondentName,_that.comment,_that.assignedToUserId,_that.completedByUserId,_that.completedAt,_that.title,_that.assignedToEmail,_that.deadline,_that.createdAt,_that.description,_that.templateSubtaskId,_that.isGeneratedFromTask);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isCompleted,  String responseGroupId,  String? respondentName,  String? comment,  String? assignedToUserId,  String? completedByUserId,  DateTime? completedAt,  String title,  String? assignedToEmail,  DateTime deadline,  DateTime? createdAt,  String? description,  String templateSubtaskId,  bool isGeneratedFromTask)  $default,) {final _that = this;
switch (_that) {
case _SubtaskCombinedListModel():
return $default(_that.id,_that.isCompleted,_that.responseGroupId,_that.respondentName,_that.comment,_that.assignedToUserId,_that.completedByUserId,_that.completedAt,_that.title,_that.assignedToEmail,_that.deadline,_that.createdAt,_that.description,_that.templateSubtaskId,_that.isGeneratedFromTask);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isCompleted,  String responseGroupId,  String? respondentName,  String? comment,  String? assignedToUserId,  String? completedByUserId,  DateTime? completedAt,  String title,  String? assignedToEmail,  DateTime deadline,  DateTime? createdAt,  String? description,  String templateSubtaskId,  bool isGeneratedFromTask)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskCombinedListModel() when $default != null:
return $default(_that.id,_that.isCompleted,_that.responseGroupId,_that.respondentName,_that.comment,_that.assignedToUserId,_that.completedByUserId,_that.completedAt,_that.title,_that.assignedToEmail,_that.deadline,_that.createdAt,_that.description,_that.templateSubtaskId,_that.isGeneratedFromTask);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtaskCombinedListModel implements SubtaskCombinedListModel {
  const _SubtaskCombinedListModel({required this.id, this.isCompleted = false, required this.responseGroupId, this.respondentName, this.comment, this.assignedToUserId, this.completedByUserId, this.completedAt, required this.title, this.assignedToEmail, required this.deadline, this.createdAt, this.description, required this.templateSubtaskId, this.isGeneratedFromTask = false});
  factory _SubtaskCombinedListModel.fromJson(Map<String, dynamic> json) => _$SubtaskCombinedListModelFromJson(json);

@override final  String id;
// ID Inštancie
@override@JsonKey() final  bool isCompleted;
@override final  String responseGroupId;
@override final  String? respondentName;
@override final  String? comment;
@override final  String? assignedToUserId;
@override final  String? completedByUserId;
@override final  DateTime? completedAt;
@override final  String title;
@override final  String? assignedToEmail;
@override final  DateTime deadline;
@override final  DateTime? createdAt;
@override final  String? description;
// Popis zo šablóny
@override final  String templateSubtaskId;
@override@JsonKey() final  bool isGeneratedFromTask;

/// Create a copy of SubtaskCombinedListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskCombinedListModelCopyWith<_SubtaskCombinedListModel> get copyWith => __$SubtaskCombinedListModelCopyWithImpl<_SubtaskCombinedListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskCombinedListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskCombinedListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.responseGroupId, responseGroupId) || other.responseGroupId == responseGroupId)&&(identical(other.respondentName, respondentName) || other.respondentName == respondentName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.assignedToUserId, assignedToUserId) || other.assignedToUserId == assignedToUserId)&&(identical(other.completedByUserId, completedByUserId) || other.completedByUserId == completedByUserId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.assignedToEmail, assignedToEmail) || other.assignedToEmail == assignedToEmail)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.templateSubtaskId, templateSubtaskId) || other.templateSubtaskId == templateSubtaskId)&&(identical(other.isGeneratedFromTask, isGeneratedFromTask) || other.isGeneratedFromTask == isGeneratedFromTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isCompleted,responseGroupId,respondentName,comment,assignedToUserId,completedByUserId,completedAt,title,assignedToEmail,deadline,createdAt,description,templateSubtaskId,isGeneratedFromTask);

@override
String toString() {
  return 'SubtaskCombinedListModel(id: $id, isCompleted: $isCompleted, responseGroupId: $responseGroupId, respondentName: $respondentName, comment: $comment, assignedToUserId: $assignedToUserId, completedByUserId: $completedByUserId, completedAt: $completedAt, title: $title, assignedToEmail: $assignedToEmail, deadline: $deadline, createdAt: $createdAt, description: $description, templateSubtaskId: $templateSubtaskId, isGeneratedFromTask: $isGeneratedFromTask)';
}


}

/// @nodoc
abstract mixin class _$SubtaskCombinedListModelCopyWith<$Res> implements $SubtaskCombinedListModelCopyWith<$Res> {
  factory _$SubtaskCombinedListModelCopyWith(_SubtaskCombinedListModel value, $Res Function(_SubtaskCombinedListModel) _then) = __$SubtaskCombinedListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isCompleted, String responseGroupId, String? respondentName, String? comment, String? assignedToUserId, String? completedByUserId, DateTime? completedAt, String title, String? assignedToEmail, DateTime deadline, DateTime? createdAt, String? description, String templateSubtaskId, bool isGeneratedFromTask
});




}
/// @nodoc
class __$SubtaskCombinedListModelCopyWithImpl<$Res>
    implements _$SubtaskCombinedListModelCopyWith<$Res> {
  __$SubtaskCombinedListModelCopyWithImpl(this._self, this._then);

  final _SubtaskCombinedListModel _self;
  final $Res Function(_SubtaskCombinedListModel) _then;

/// Create a copy of SubtaskCombinedListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isCompleted = null,Object? responseGroupId = null,Object? respondentName = freezed,Object? comment = freezed,Object? assignedToUserId = freezed,Object? completedByUserId = freezed,Object? completedAt = freezed,Object? title = null,Object? assignedToEmail = freezed,Object? deadline = null,Object? createdAt = freezed,Object? description = freezed,Object? templateSubtaskId = null,Object? isGeneratedFromTask = null,}) {
  return _then(_SubtaskCombinedListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,responseGroupId: null == responseGroupId ? _self.responseGroupId : responseGroupId // ignore: cast_nullable_to_non_nullable
as String,respondentName: freezed == respondentName ? _self.respondentName : respondentName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,assignedToUserId: freezed == assignedToUserId ? _self.assignedToUserId : assignedToUserId // ignore: cast_nullable_to_non_nullable
as String?,completedByUserId: freezed == completedByUserId ? _self.completedByUserId : completedByUserId // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,assignedToEmail: freezed == assignedToEmail ? _self.assignedToEmail : assignedToEmail // ignore: cast_nullable_to_non_nullable
as String?,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,templateSubtaskId: null == templateSubtaskId ? _self.templateSubtaskId : templateSubtaskId // ignore: cast_nullable_to_non_nullable
as String,isGeneratedFromTask: null == isGeneratedFromTask ? _self.isGeneratedFromTask : isGeneratedFromTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
