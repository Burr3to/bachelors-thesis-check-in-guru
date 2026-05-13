// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_summary_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskSummaryStats _$TaskSummaryStatsFromJson(Map<String, dynamic> json) =>
    _TaskSummaryStats(
      taskId: json['taskId'] as String,
      mode: $enumDecode(_$SubtaskModeEnumMap, json['mode']),
      globalProgress: (json['globalProgress'] as num).toDouble(),
      totalRespondents: (json['totalRespondents'] as num?)?.toInt() ?? 0,
      completedFull: (json['completedFull'] as num?)?.toInt() ?? 0,
      inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      notStarted: (json['notStarted'] as num?)?.toInt() ?? 0,
      totalSubtasks: (json['totalSubtasks'] as num?)?.toInt() ?? 0,
      completedSubtasks: (json['completedSubtasks'] as num?)?.toInt() ?? 0,
      completedOnTime: (json['completedOnTime'] as num?)?.toInt() ?? 0,
      issuesCount: (json['issuesCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TaskSummaryStatsToJson(_TaskSummaryStats instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'mode': _$SubtaskModeEnumMap[instance.mode]!,
      'globalProgress': instance.globalProgress,
      'totalRespondents': instance.totalRespondents,
      'completedFull': instance.completedFull,
      'inProgress': instance.inProgress,
      'notStarted': instance.notStarted,
      'totalSubtasks': instance.totalSubtasks,
      'completedSubtasks': instance.completedSubtasks,
      'completedOnTime': instance.completedOnTime,
      'issuesCount': instance.issuesCount,
    };

const _$SubtaskModeEnumMap = {SubtaskMode.shared: 0, SubtaskMode.individual: 1};
