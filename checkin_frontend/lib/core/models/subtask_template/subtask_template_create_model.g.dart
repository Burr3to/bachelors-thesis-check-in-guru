// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_template_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskTemplateCreateModel _$SubtaskTemplateCreateModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskTemplateCreateModel(
  title: json['title'] as String,
  description: json['description'] as String?,
  parentTaskId:
      json['parentTaskId'] as String? ?? '00000000-0000-0000-0000-000000000000',
);

Map<String, dynamic> _$SubtaskTemplateCreateModelToJson(
  _SubtaskTemplateCreateModel instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'parentTaskId': instance.parentTaskId,
};
