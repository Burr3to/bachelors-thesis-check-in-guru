// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_instance_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskInstanceListModel _$SubtaskInstanceListModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskInstanceListModel(
  id: json['id'] as String,
  templateSubtaskId: json['templateSubtaskId'] as String,
  assignedToUserId: json['assignedToUserId'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedByUserId: json['completedByUserId'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$SubtaskInstanceListModelToJson(
  _SubtaskInstanceListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'templateSubtaskId': instance.templateSubtaskId,
  'assignedToUserId': instance.assignedToUserId,
  'isCompleted': instance.isCompleted,
  'completedByUserId': instance.completedByUserId,
  'completedAt': instance.completedAt?.toIso8601String(),
};
