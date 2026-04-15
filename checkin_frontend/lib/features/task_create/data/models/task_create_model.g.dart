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
      subtaskMode: $enumDecode(_$SubtaskModeEnumMap, json['subtaskMode']),
      requiresAuthenticationToComplete:
          json['requiresAuthenticationToComplete'] as bool? ?? true,
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map(
                (e) => SubtaskTemplateCreateModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      invitedEmails:
          (json['invitedEmails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sendInvitesImmediately: json['sendInvitesImmediately'] as bool? ?? false,
    );

Map<String, dynamic> _$TaskCreateModelToJson(
  _TaskCreateModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'notes': instance.notes,
  'deadLine': instance.deadLine.toIso8601String(),
  'subtaskMode': _$SubtaskModeEnumMap[instance.subtaskMode]!,
  'requiresAuthenticationToComplete': instance.requiresAuthenticationToComplete,
  'subtasks': instance.subtasks,
  'invitedEmails': instance.invitedEmails,
  'sendInvitesImmediately': instance.sendInvitesImmediately,
};

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 1, SubtaskMode.individual: 2};
