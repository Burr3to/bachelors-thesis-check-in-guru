// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_subtask_complete_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BulkSubtaskCompleteModel _$BulkSubtaskCompleteModelFromJson(
  Map<String, dynamic> json,
) => _BulkSubtaskCompleteModel(
  instanceIds: (json['instanceIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  respondentName: json['respondentName'] as String,
);

Map<String, dynamic> _$BulkSubtaskCompleteModelToJson(
  _BulkSubtaskCompleteModel instance,
) => <String, dynamic>{
  'instanceIds': instance.instanceIds,
  'respondentName': instance.respondentName,
};
