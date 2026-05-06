// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulk_subtask_complete_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BulkSubtaskCompleteModel {

 List<String> get instanceIds; String get respondentName;
/// Create a copy of BulkSubtaskCompleteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulkSubtaskCompleteModelCopyWith<BulkSubtaskCompleteModel> get copyWith => _$BulkSubtaskCompleteModelCopyWithImpl<BulkSubtaskCompleteModel>(this as BulkSubtaskCompleteModel, _$identity);

  /// Serializes this BulkSubtaskCompleteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulkSubtaskCompleteModel&&const DeepCollectionEquality().equals(other.instanceIds, instanceIds)&&(identical(other.respondentName, respondentName) || other.respondentName == respondentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(instanceIds),respondentName);

@override
String toString() {
  return 'BulkSubtaskCompleteModel(instanceIds: $instanceIds, respondentName: $respondentName)';
}


}

/// @nodoc
abstract mixin class $BulkSubtaskCompleteModelCopyWith<$Res>  {
  factory $BulkSubtaskCompleteModelCopyWith(BulkSubtaskCompleteModel value, $Res Function(BulkSubtaskCompleteModel) _then) = _$BulkSubtaskCompleteModelCopyWithImpl;
@useResult
$Res call({
 List<String> instanceIds, String respondentName
});




}
/// @nodoc
class _$BulkSubtaskCompleteModelCopyWithImpl<$Res>
    implements $BulkSubtaskCompleteModelCopyWith<$Res> {
  _$BulkSubtaskCompleteModelCopyWithImpl(this._self, this._then);

  final BulkSubtaskCompleteModel _self;
  final $Res Function(BulkSubtaskCompleteModel) _then;

/// Create a copy of BulkSubtaskCompleteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? instanceIds = null,Object? respondentName = null,}) {
  return _then(_self.copyWith(
instanceIds: null == instanceIds ? _self.instanceIds : instanceIds // ignore: cast_nullable_to_non_nullable
as List<String>,respondentName: null == respondentName ? _self.respondentName : respondentName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BulkSubtaskCompleteModel].
extension BulkSubtaskCompleteModelPatterns on BulkSubtaskCompleteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulkSubtaskCompleteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulkSubtaskCompleteModel value)  $default,){
final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulkSubtaskCompleteModel value)?  $default,){
final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> instanceIds,  String respondentName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel() when $default != null:
return $default(_that.instanceIds,_that.respondentName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> instanceIds,  String respondentName)  $default,) {final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel():
return $default(_that.instanceIds,_that.respondentName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> instanceIds,  String respondentName)?  $default,) {final _that = this;
switch (_that) {
case _BulkSubtaskCompleteModel() when $default != null:
return $default(_that.instanceIds,_that.respondentName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BulkSubtaskCompleteModel implements BulkSubtaskCompleteModel {
  const _BulkSubtaskCompleteModel({required final  List<String> instanceIds, required this.respondentName}): _instanceIds = instanceIds;
  factory _BulkSubtaskCompleteModel.fromJson(Map<String, dynamic> json) => _$BulkSubtaskCompleteModelFromJson(json);

 final  List<String> _instanceIds;
@override List<String> get instanceIds {
  if (_instanceIds is EqualUnmodifiableListView) return _instanceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instanceIds);
}

@override final  String respondentName;

/// Create a copy of BulkSubtaskCompleteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkSubtaskCompleteModelCopyWith<_BulkSubtaskCompleteModel> get copyWith => __$BulkSubtaskCompleteModelCopyWithImpl<_BulkSubtaskCompleteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BulkSubtaskCompleteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkSubtaskCompleteModel&&const DeepCollectionEquality().equals(other._instanceIds, _instanceIds)&&(identical(other.respondentName, respondentName) || other.respondentName == respondentName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_instanceIds),respondentName);

@override
String toString() {
  return 'BulkSubtaskCompleteModel(instanceIds: $instanceIds, respondentName: $respondentName)';
}


}

/// @nodoc
abstract mixin class _$BulkSubtaskCompleteModelCopyWith<$Res> implements $BulkSubtaskCompleteModelCopyWith<$Res> {
  factory _$BulkSubtaskCompleteModelCopyWith(_BulkSubtaskCompleteModel value, $Res Function(_BulkSubtaskCompleteModel) _then) = __$BulkSubtaskCompleteModelCopyWithImpl;
@override @useResult
$Res call({
 List<String> instanceIds, String respondentName
});




}
/// @nodoc
class __$BulkSubtaskCompleteModelCopyWithImpl<$Res>
    implements _$BulkSubtaskCompleteModelCopyWith<$Res> {
  __$BulkSubtaskCompleteModelCopyWithImpl(this._self, this._then);

  final _BulkSubtaskCompleteModel _self;
  final $Res Function(_BulkSubtaskCompleteModel) _then;

/// Create a copy of BulkSubtaskCompleteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? instanceIds = null,Object? respondentName = null,}) {
  return _then(_BulkSubtaskCompleteModel(
instanceIds: null == instanceIds ? _self._instanceIds : instanceIds // ignore: cast_nullable_to_non_nullable
as List<String>,respondentName: null == respondentName ? _self.respondentName : respondentName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
