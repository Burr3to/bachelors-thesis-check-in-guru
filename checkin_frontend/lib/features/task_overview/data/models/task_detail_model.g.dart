// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskDetailModel _$TaskDetailModelFromJson(Map<String, dynamic> json) =>
    _TaskDetailModel(
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
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map(
                (e) => SubtaskTemplateListModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TaskDetailModelToJson(
  _TaskDetailModel instance,
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
  'subtasks': instance.subtasks,
};

const _$TaskStateEnumMap = {
  TaskState.todo: 0,
  TaskState.inProgress: 1,
  TaskState.completed: 2,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 1, SubtaskMode.individual: 2};
