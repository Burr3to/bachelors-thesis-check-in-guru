// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_template_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtaskTemplateDetailModel {

 String get id; String get title; String? get description; String get parentTaskId; DateTime? get createdAt; bool get isGeneratedFromTask;
/// Create a copy of SubtaskTemplateDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskTemplateDetailModelCopyWith<SubtaskTemplateDetailModel> get copyWith => _$SubtaskTemplateDetailModelCopyWithImpl<SubtaskTemplateDetailModel>(this as SubtaskTemplateDetailModel, _$identity);

  /// Serializes this SubtaskTemplateDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskTemplateDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.parentTaskId, parentTaskId) || other.parentTaskId == parentTaskId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isGeneratedFromTask, isGeneratedFromTask) || other.isGeneratedFromTask == isGeneratedFromTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,parentTaskId,createdAt,isGeneratedFromTask);

@override
String toString() {
  return 'SubtaskTemplateDetailModel(id: $id, title: $title, description: $description, parentTaskId: $parentTaskId, createdAt: $createdAt, isGeneratedFromTask: $isGeneratedFromTask)';
}


}

/// @nodoc
abstract mixin class $SubtaskTemplateDetailModelCopyWith<$Res>  {
  factory $SubtaskTemplateDetailModelCopyWith(SubtaskTemplateDetailModel value, $Res Function(SubtaskTemplateDetailModel) _then) = _$SubtaskTemplateDetailModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String parentTaskId, DateTime? createdAt, bool isGeneratedFromTask
});




}
/// @nodoc
class _$SubtaskTemplateDetailModelCopyWithImpl<$Res>
    implements $SubtaskTemplateDetailModelCopyWith<$Res> {
  _$SubtaskTemplateDetailModelCopyWithImpl(this._self, this._then);

  final SubtaskTemplateDetailModel _self;
  final $Res Function(SubtaskTemplateDetailModel) _then;

/// Create a copy of SubtaskTemplateDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? parentTaskId = null,Object? createdAt = freezed,Object? isGeneratedFromTask = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parentTaskId: null == parentTaskId ? _self.parentTaskId : parentTaskId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isGeneratedFromTask: null == isGeneratedFromTask ? _self.isGeneratedFromTask : isGeneratedFromTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskTemplateDetailModel].
extension SubtaskTemplateDetailModelPatterns on SubtaskTemplateDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskTemplateDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskTemplateDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskTemplateDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String parentTaskId,  DateTime? createdAt,  bool isGeneratedFromTask)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.parentTaskId,_that.createdAt,_that.isGeneratedFromTask);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String parentTaskId,  DateTime? createdAt,  bool isGeneratedFromTask)  $default,) {final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel():
return $default(_that.id,_that.title,_that.description,_that.parentTaskId,_that.createdAt,_that.isGeneratedFromTask);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String parentTaskId,  DateTime? createdAt,  bool isGeneratedFromTask)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskTemplateDetailModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.parentTaskId,_that.createdAt,_that.isGeneratedFromTask);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtaskTemplateDetailModel implements SubtaskTemplateDetailModel {
  const _SubtaskTemplateDetailModel({required this.id, required this.title, this.description, required this.parentTaskId, this.createdAt, this.isGeneratedFromTask = false});
  factory _SubtaskTemplateDetailModel.fromJson(Map<String, dynamic> json) => _$SubtaskTemplateDetailModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String parentTaskId;
@override final  DateTime? createdAt;
@override@JsonKey() final  bool isGeneratedFromTask;

/// Create a copy of SubtaskTemplateDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskTemplateDetailModelCopyWith<_SubtaskTemplateDetailModel> get copyWith => __$SubtaskTemplateDetailModelCopyWithImpl<_SubtaskTemplateDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskTemplateDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskTemplateDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.parentTaskId, parentTaskId) || other.parentTaskId == parentTaskId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isGeneratedFromTask, isGeneratedFromTask) || other.isGeneratedFromTask == isGeneratedFromTask));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,parentTaskId,createdAt,isGeneratedFromTask);

@override
String toString() {
  return 'SubtaskTemplateDetailModel(id: $id, title: $title, description: $description, parentTaskId: $parentTaskId, createdAt: $createdAt, isGeneratedFromTask: $isGeneratedFromTask)';
}


}

/// @nodoc
abstract mixin class _$SubtaskTemplateDetailModelCopyWith<$Res> implements $SubtaskTemplateDetailModelCopyWith<$Res> {
  factory _$SubtaskTemplateDetailModelCopyWith(_SubtaskTemplateDetailModel value, $Res Function(_SubtaskTemplateDetailModel) _then) = __$SubtaskTemplateDetailModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String parentTaskId, DateTime? createdAt, bool isGeneratedFromTask
});




}
/// @nodoc
class __$SubtaskTemplateDetailModelCopyWithImpl<$Res>
    implements _$SubtaskTemplateDetailModelCopyWith<$Res> {
  __$SubtaskTemplateDetailModelCopyWithImpl(this._self, this._then);

  final _SubtaskTemplateDetailModel _self;
  final $Res Function(_SubtaskTemplateDetailModel) _then;

/// Create a copy of SubtaskTemplateDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? parentTaskId = null,Object? createdAt = freezed,Object? isGeneratedFromTask = null,}) {
  return _then(_SubtaskTemplateDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parentTaskId: null == parentTaskId ? _self.parentTaskId : parentTaskId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isGeneratedFromTask: null == isGeneratedFromTask ? _self.isGeneratedFromTask : isGeneratedFromTask // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
