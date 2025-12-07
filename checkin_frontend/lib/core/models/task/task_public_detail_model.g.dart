// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_public_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskPublicDetailModel _$TaskPublicDetailModelFromJson(
  Map<String, dynamic> json,
) => _TaskPublicDetailModel(
  id: json['id'] as String,
  title: json['title'] as String,
  notes: json['notes'] as String?,
  deadLine: DateTime.parse(json['deadLine'] as String),
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  subtaskMode: $enumDecode(_$SubtaskModeEnumMap, json['subtaskMode']),
  requiresAuthenticationToComplete:
      json['requiresAuthenticationToComplete'] as bool,
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map(
            (e) => SubtaskCombinedListModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$TaskPublicDetailModelToJson(
  _TaskPublicDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'notes': instance.notes,
  'deadLine': instance.deadLine.toIso8601String(),
  'status': _$TaskStatusEnumMap[instance.status]!,
  'subtaskMode': _$SubtaskModeEnumMap[instance.subtaskMode]!,
  'requiresAuthenticationToComplete': instance.requiresAuthenticationToComplete,
  'subtasks': instance.subtasks,
};

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 0,
  TaskStatus.inProgress: 1,
  TaskStatus.completed: 2,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 1, SubtaskMode.individual: 2};
