import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/task_enums.dart';

part 'task_summary_stats.freezed.dart';
part 'task_summary_stats.g.dart';

@freezed
sealed class TaskSummaryStats with _$TaskSummaryStats {
  const factory TaskSummaryStats({
    required String taskId,
    required SubtaskMode mode,
    required double globalProgress,

    @Default(0) int totalRespondents,
    @Default(0) int completedFull,
    @Default(0) int inProgress,
    @Default(0) int notStarted,
    @Default(0) int totalSubtasks,
    @Default(0) int completedSubtasks,
    @Default(0) int completedOnTime,
    @Default(0) int issuesCount,
  }) = _TaskSummaryStats;

  factory TaskSummaryStats.fromJson(Map<String, dynamic> json) =>
      _$TaskSummaryStatsFromJson(json);
}