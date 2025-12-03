// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskDetailModel _$TaskDetailModelFromJson(Map<String, dynamic> json) =>
    _TaskDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      hash: json['hash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadLine: DateTime.parse(json['deadLine'] as String),
      createdById: json['createdById'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TaskDetailModelToJson(_TaskDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hash': instance.hash,
      'createdAt': instance.createdAt.toIso8601String(),
      'deadLine': instance.deadLine.toIso8601String(),
      'createdById': instance.createdById,
      'notes': instance.notes,
    };
