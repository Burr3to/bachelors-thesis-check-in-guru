// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskListQuery _$TaskListQueryFromJson(Map<String, dynamic> json) =>
    _TaskListQuery(
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 12,
      sortBy: json['sortBy'] as String? ?? "createdat",
      sortDesc: json['sortDesc'] as bool? ?? true,
      nameContains: json['nameContains'] as String?,
      status: $enumDecodeNullable(_$TaskStateEnumMap, json['status']),
      deadLineBefore: json['deadLineBefore'] == null
          ? null
          : DateTime.parse(json['deadLineBefore'] as String),
      deadLineAfter: json['deadLineAfter'] == null
          ? null
          : DateTime.parse(json['deadLineAfter'] as String),
      mode: $enumDecodeNullable(_$SubtaskModeEnumMap, json['mode']),
      requiresAuth: json['requiresAuth'] as bool?,
      respondentEmail: json['respondentEmail'] as String?,
    );

Map<String, dynamic> _$TaskListQueryToJson(_TaskListQuery instance) =>
    <String, dynamic>{
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'sortBy': instance.sortBy,
      'sortDesc': instance.sortDesc,
      'nameContains': instance.nameContains,
      'status': _$TaskStateEnumMap[instance.status],
      'deadLineBefore': instance.deadLineBefore?.toIso8601String(),
      'deadLineAfter': instance.deadLineAfter?.toIso8601String(),
      'mode': _$SubtaskModeEnumMap[instance.mode],
      'requiresAuth': instance.requiresAuth,
      'respondentEmail': instance.respondentEmail,
    };

const _$TaskStateEnumMap = {
  TaskState.todo: 0,
  TaskState.inProgress: 1,
  TaskState.completed: 2,
  TaskState.missed: 3,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 0, SubtaskMode.individual: 1};
