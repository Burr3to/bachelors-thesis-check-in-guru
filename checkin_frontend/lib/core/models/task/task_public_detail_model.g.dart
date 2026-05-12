// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_public_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskPublicDetailModel _$TaskPublicDetailModelFromJson(
  Map<String, dynamic> json,
) => _TaskPublicDetailModel(
  id: json['id'] as String?,
  hash: json['hash'] as String?,
  title: json['title'] as String? ?? '',
  notes: json['notes'] as String?,
  deadLine: json['deadLine'] == null
      ? null
      : DateTime.parse(json['deadLine'] as String),
  state:
      $enumDecodeNullable(_$TaskStateEnumMap, json['state']) ??
      TaskState.inProgress,
  subtaskMode:
      $enumDecodeNullable(_$SubtaskModeEnumMap, json['subtaskMode']) ??
      SubtaskMode.individual,
  requiresAuthenticationToComplete:
      json['requiresAuthenticationToComplete'] as bool? ?? false,
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map(
            (e) => SubtaskCombinedListModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  allowedDomain: json['allowedDomain'] as String?,
  isForbidden: json['isForbidden'] as bool? ?? false,
  forbiddenMessage: json['forbiddenMessage'] as String?,
);

Map<String, dynamic> _$TaskPublicDetailModelToJson(
  _TaskPublicDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'hash': instance.hash,
  'title': instance.title,
  'notes': instance.notes,
  'deadLine': instance.deadLine?.toIso8601String(),
  'state': _$TaskStateEnumMap[instance.state]!,
  'subtaskMode': _$SubtaskModeEnumMap[instance.subtaskMode]!,
  'requiresAuthenticationToComplete': instance.requiresAuthenticationToComplete,
  'subtasks': instance.subtasks,
  'allowedDomain': instance.allowedDomain,
  'isForbidden': instance.isForbidden,
  'forbiddenMessage': instance.forbiddenMessage,
};

const _$TaskStateEnumMap = {
  TaskState.todo: 0,
  TaskState.inProgress: 1,
  TaskState.completed: 2,
  TaskState.missed: 3,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 0, SubtaskMode.individual: 1};
