// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_template_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskTemplateDetailModel _$SubtaskTemplateDetailModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskTemplateDetailModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  parentTaskId: json['parentTaskId'] as String,
  isGeneratedFromTask: json['isGeneratedFromTask'] as bool? ?? false,
);

Map<String, dynamic> _$SubtaskTemplateDetailModelToJson(
  _SubtaskTemplateDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'parentTaskId': instance.parentTaskId,
  'isGeneratedFromTask': instance.isGeneratedFromTask,
};
