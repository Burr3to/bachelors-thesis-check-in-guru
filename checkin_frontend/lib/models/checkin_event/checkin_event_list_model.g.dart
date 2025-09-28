// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_event_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInEventListModelImpl _$$CheckInEventListModelImplFromJson(
  Map<String, dynamic> json,
) => _$CheckInEventListModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  hash: json['hash'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  ownerId: json['ownerId'] as String,
);

Map<String, dynamic> _$$CheckInEventListModelImplToJson(
  _$CheckInEventListModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'hash': instance.hash,
  'createdAt': instance.createdAt.toIso8601String(),
  'ownerId': instance.ownerId,
};
