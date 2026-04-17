// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskUpdateModel _$TaskUpdateModelFromJson(Map<String, dynamic> json) =>
    _TaskUpdateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      deadLine: DateTime.parse(json['deadLine'] as String),
      invitedEmails:
          (json['invitedEmails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map(
                (e) => SubtaskTemplateCreateModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TaskUpdateModelToJson(_TaskUpdateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'notes': instance.notes,
      'deadLine': instance.deadLine.toIso8601String(),
      'invitedEmails': instance.invitedEmails,
      'subtasks': instance.subtasks,
    };
