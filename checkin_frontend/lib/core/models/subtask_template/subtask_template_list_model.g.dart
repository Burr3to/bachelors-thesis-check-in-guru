// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_template_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskTemplateListModel _$SubtaskTemplateListModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskTemplateListModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  parentTaskId: json['parentTaskId'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isGeneratedFromTask: json['isGeneratedFromTask'] as bool? ?? false,
);

Map<String, dynamic> _$SubtaskTemplateListModelToJson(
  _SubtaskTemplateListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'parentTaskId': instance.parentTaskId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isGeneratedFromTask': instance.isGeneratedFromTask,
};
