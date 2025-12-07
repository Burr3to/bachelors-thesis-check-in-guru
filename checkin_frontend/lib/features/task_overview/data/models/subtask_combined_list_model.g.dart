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
  assignedToUserId: json['assignedToUserId'] as String?,
  completedByUserId: json['completedByUserId'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  title: json['title'] as String,
  description: json['description'] as String?,
  templateSubtaskId: json['templateSubtaskId'] as String,
);

Map<String, dynamic> _$SubtaskCombinedListModelToJson(
  _SubtaskCombinedListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'isCompleted': instance.isCompleted,
  'assignedToUserId': instance.assignedToUserId,
  'completedByUserId': instance.completedByUserId,
  'completedAt': instance.completedAt?.toIso8601String(),
  'title': instance.title,
  'description': instance.description,
  'templateSubtaskId': instance.templateSubtaskId,
};
