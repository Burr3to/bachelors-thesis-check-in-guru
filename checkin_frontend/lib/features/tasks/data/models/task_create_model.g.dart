// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskCreateModel _$TaskCreateModelFromJson(Map<String, dynamic> json) =>
    _TaskCreateModel(
      title: json['title'] as String,
      notes: json['notes'] as String?,
      deadLine: DateTime.parse(json['deadLine'] as String),
    );

Map<String, dynamic> _$TaskCreateModelToJson(_TaskCreateModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'notes': instance.notes,
      'deadLine': instance.deadLine.toIso8601String(),
    };
