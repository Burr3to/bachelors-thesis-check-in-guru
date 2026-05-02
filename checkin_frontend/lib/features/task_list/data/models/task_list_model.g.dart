// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskListModel _$TaskListModelFromJson(Map<String, dynamic> json) =>
    _TaskListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      hash: json['hash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadLine: DateTime.parse(json['deadLine'] as String),
      createdById: json['createdById'] as String,
      state: $enumDecode(_$TaskStateEnumMap, json['state']),
      subtaskMode: $enumDecode(_$SubtaskModeEnumMap, json['subtaskMode']),
      requiresAuthenticationToComplete:
          json['requiresAuthenticationToComplete'] as bool? ?? true,
      allowedDomain: json['allowedDomain'] as String?,
    );

Map<String, dynamic> _$TaskListModelToJson(
  _TaskListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'notes': instance.notes,
  'hash': instance.hash,
  'createdAt': instance.createdAt.toIso8601String(),
  'deadLine': instance.deadLine.toIso8601String(),
  'createdById': instance.createdById,
  'state': _$TaskStateEnumMap[instance.state]!,
  'subtaskMode': _$SubtaskModeEnumMap[instance.subtaskMode]!,
  'requiresAuthenticationToComplete': instance.requiresAuthenticationToComplete,
  'allowedDomain': instance.allowedDomain,
};

const _$TaskStateEnumMap = {
  TaskState.todo: 0,
  TaskState.inProgress: 1,
  TaskState.completed: 2,
  TaskState.missed: 3,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 0, SubtaskMode.individual: 1};
