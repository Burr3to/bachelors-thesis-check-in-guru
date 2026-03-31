// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_combined_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskCombinedListModel _$SubtaskCombinedListModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskCombinedListModel(
  id: json['id'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  responseGroupId: json['responseGroupId'] as String,
  respondentName: json['respondentName'] as String?,
  comment: json['comment'] as String?,
  assignedToUserId: json['assignedToUserId'] as String?,
  completedByUserId: json['completedByUserId'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  title: json['title'] as String,
  assignedToEmail: json['assignedToEmail'] as String?,
  description: json['description'] as String?,
  templateSubtaskId: json['templateSubtaskId'] as String,
  isGeneratedFromTask: json['isGeneratedFromTask'] as bool? ?? false,
);

Map<String, dynamic> _$SubtaskCombinedListModelToJson(
  _SubtaskCombinedListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'isCompleted': instance.isCompleted,
  'responseGroupId': instance.responseGroupId,
  'respondentName': instance.respondentName,
  'comment': instance.comment,
  'assignedToUserId': instance.assignedToUserId,
  'completedByUserId': instance.completedByUserId,
  'completedAt': instance.completedAt?.toIso8601String(),
  'title': instance.title,
  'assignedToEmail': instance.assignedToEmail,
  'description': instance.description,
  'templateSubtaskId': instance.templateSubtaskId,
  'isGeneratedFromTask': instance.isGeneratedFromTask,
};
