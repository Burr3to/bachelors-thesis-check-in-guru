// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_template_create_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubtaskTemplateCreateModel {

 String get title; String? get description;// Pri vytváraní nového tasku toto ID ešte nemáme,
// ale ak to backend vyžaduje v modeli, musíme to tam dať (môžeš poslať prázdny string alebo null ak dovolí)
 String get parentTaskId;
/// Create a copy of SubtaskTemplateCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskTemplateCreateModelCopyWith<SubtaskTemplateCreateModel> get copyWith => _$SubtaskTemplateCreateModelCopyWithImpl<SubtaskTemplateCreateModel>(this as SubtaskTemplateCreateModel, _$identity);

  /// Serializes this SubtaskTemplateCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtaskTemplateCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.parentTaskId, parentTaskId) || other.parentTaskId == parentTaskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,parentTaskId);

@override
String toString() {
  return 'SubtaskTemplateCreateModel(title: $title, description: $description, parentTaskId: $parentTaskId)';
}


}

/// @nodoc
abstract mixin class $SubtaskTemplateCreateModelCopyWith<$Res>  {
  factory $SubtaskTemplateCreateModelCopyWith(SubtaskTemplateCreateModel value, $Res Function(SubtaskTemplateCreateModel) _then) = _$SubtaskTemplateCreateModelCopyWithImpl;
@useResult
$Res call({
 String title, String? description, String parentTaskId
});




}
/// @nodoc
class _$SubtaskTemplateCreateModelCopyWithImpl<$Res>
    implements $SubtaskTemplateCreateModelCopyWith<$Res> {
  _$SubtaskTemplateCreateModelCopyWithImpl(this._self, this._then);

  final SubtaskTemplateCreateModel _self;
  final $Res Function(SubtaskTemplateCreateModel) _then;

/// Create a copy of SubtaskTemplateCreateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = freezed,Object? parentTaskId = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parentTaskId: null == parentTaskId ? _self.parentTaskId : parentTaskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtaskTemplateCreateModel].
extension SubtaskTemplateCreateModelPatterns on SubtaskTemplateCreateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtaskTemplateCreateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtaskTemplateCreateModel value)  $default,){
final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtaskTemplateCreateModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? description,  String parentTaskId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel() when $default != null:
return $default(_that.title,_that.description,_that.parentTaskId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? description,  String parentTaskId)  $default,) {final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel():
return $default(_that.title,_that.description,_that.parentTaskId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? description,  String parentTaskId)?  $default,) {final _that = this;
switch (_that) {
case _SubtaskTemplateCreateModel() when $default != null:
return $default(_that.title,_that.description,_that.parentTaskId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtaskTemplateCreateModel implements SubtaskTemplateCreateModel {
  const _SubtaskTemplateCreateModel({required this.title, this.description, this.parentTaskId = '00000000-0000-0000-0000-000000000000'});
  factory _SubtaskTemplateCreateModel.fromJson(Map<String, dynamic> json) => _$SubtaskTemplateCreateModelFromJson(json);

@override final  String title;
@override final  String? description;
// Pri vytváraní nového tasku toto ID ešte nemáme,
// ale ak to backend vyžaduje v modeli, musíme to tam dať (môžeš poslať prázdny string alebo null ak dovolí)
@override@JsonKey() final  String parentTaskId;

/// Create a copy of SubtaskTemplateCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskTemplateCreateModelCopyWith<_SubtaskTemplateCreateModel> get copyWith => __$SubtaskTemplateCreateModelCopyWithImpl<_SubtaskTemplateCreateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtaskTemplateCreateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtaskTemplateCreateModel&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.parentTaskId, parentTaskId) || other.parentTaskId == parentTaskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,parentTaskId);

@override
String toString() {
  return 'SubtaskTemplateCreateModel(title: $title, description: $description, parentTaskId: $parentTaskId)';
}


}

/// @nodoc
abstract mixin class _$SubtaskTemplateCreateModelCopyWith<$Res> implements $SubtaskTemplateCreateModelCopyWith<$Res> {
  factory _$SubtaskTemplateCreateModelCopyWith(_SubtaskTemplateCreateModel value, $Res Function(_SubtaskTemplateCreateModel) _then) = __$SubtaskTemplateCreateModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String? description, String parentTaskId
});




}
/// @nodoc
class __$SubtaskTemplateCreateModelCopyWithImpl<$Res>
    implements _$SubtaskTemplateCreateModelCopyWith<$Res> {
  __$SubtaskTemplateCreateModelCopyWithImpl(this._self, this._then);

  final _SubtaskTemplateCreateModel _self;
  final $Res Function(_SubtaskTemplateCreateModel) _then;

/// Create a copy of SubtaskTemplateCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = freezed,Object? parentTaskId = null,}) {
  return _then(_SubtaskTemplateCreateModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,parentTaskId: null == parentTaskId ? _self.parentTaskId : parentTaskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
