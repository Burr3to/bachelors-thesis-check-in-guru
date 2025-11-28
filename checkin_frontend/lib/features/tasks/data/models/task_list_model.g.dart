// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskListModel _$TaskListModelFromJson(Map<String, dynamic> json) =>
    _TaskListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      hash: json['hash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadLine: DateTime.parse(json['deadLine'] as String),
      createdById: json['createdById'] as String,
    );

Map<String, dynamic> _$TaskListModelToJson(_TaskListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hash': instance.hash,
      'createdAt': instance.createdAt.toIso8601String(),
      'deadLine': instance.deadLine.toIso8601String(),
      'createdById': instance.createdById,
    };
