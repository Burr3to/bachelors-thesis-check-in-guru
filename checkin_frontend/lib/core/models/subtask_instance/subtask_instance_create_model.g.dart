// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_instance_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubtaskInstanceCreateModel _$SubtaskInstanceCreateModelFromJson(
  Map<String, dynamic> json,
) => _SubtaskInstanceCreateModel(
  templateSubtaskId: json['templateSubtaskId'] as String,
  assignedToUserId: json['assignedToUserId'] as String?,
);

Map<String, dynamic> _$SubtaskInstanceCreateModelToJson(
  _SubtaskInstanceCreateModel instance,
) => <String, dynamic>{
  'templateSubtaskId': instance.templateSubtaskId,
  'assignedToUserId': instance.assignedToUserId,
};
