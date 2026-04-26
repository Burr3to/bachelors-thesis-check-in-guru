// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_template_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskTemplateUpdateModel _$SubtaskTemplateUpdateModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskTemplateUpdateModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SubtaskTemplateUpdateModelToJson(
  _SubtaskTemplateUpdateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
};
