import 'package:checkin_frontend/core/models/Statistics/task_summary_stats.dart';
import 'package:checkin_frontend/core/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/enums/task_enums.dart';

/// A segmented progress bar that visualizes completion status.
/// Logic differs based on SubtaskMode:
/// - Shared: Shows subtask completion (On time vs Late).
/// - Individual: Shows respondent progress (Completed, In Progress, Pending).
class TaskProgressBar extends ConsumerWidget {
  final String taskId;

  const TaskProgressBar({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStatsAsync = ref.watch(allTaskStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return allStatsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (err, stack) => const SizedBox.shrink(),
      data: (statsMap) {
        // Retrieve statistics specific to this task card
        final stats = statsMap[taskId];

        if (stats == null) return const SizedBox.shrink();

        return _buildProgressBar(context, colorScheme, stats);
      },
    );
  }

  /// Builds the progress bar container and the accompanying numeric label.
  Widget _buildProgressBar(BuildContext context, ColorScheme colorScheme, TaskSummaryStats stats) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: _buildSegments(colorScheme, stats),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: _buildRightLabel(colorScheme, stats),
        ),
      ],
    );
  }

  /// Generates the colored segments for the progress bar.
  /// Colors: Green (On time), Red (Late/Issue), Orange (In Progress), Gray (Remaining).
  List<Widget> _buildSegments(ColorScheme colorScheme, TaskSummaryStats stats) {
    final emptyColor = colorScheme.surfaceContainerHighest;

    if (stats.mode == SubtaskMode.shared) {
      // SHARED MODE: Tracks individual subtask instances
      return [
        if (stats.completedOnTime > 0)
          Expanded(flex: stats.completedOnTime, child: Container(color: Colors.green.shade400)),
        if (stats.issuesCount > 0)
          Expanded(flex: stats.issuesCount, child: Container(color: Colors.red.shade400)),
        if (stats.notStarted > 0 || stats.totalSubtasks == 0)
          Expanded(
              flex: stats.notStarted == 0 && stats.totalSubtasks == 0 ? 1 : stats.notStarted,
              child: Container(color: emptyColor)),
      ];
    } else {
      // INDIVIDUAL MODE: Tracks statuses of invited respondents
      final total = stats.totalRespondents;
      return [
        if (stats.completedOnTime > 0)
          Expanded(flex: stats.completedOnTime, child: Container(color: Colors.green.shade400)),
        if (stats.issuesCount > 0)
          Expanded(flex: stats.issuesCount, child: Container(color: Colors.red.shade400)),
        if (stats.inProgress > 0)
          Expanded(flex: stats.inProgress, child: Container(color: Colors.orange.shade300)),
        if (stats.notStarted > 0 || total == 0)
          Expanded(
              flex: stats.notStarted == 0 && total == 0 ? 1 : stats.notStarted,
              child: Container(color: emptyColor)),
      ];
    }
  }

  /// Builds the right-side label showing either a ratio (Shared) or participant count (Individual).
  Widget _buildRightLabel(ColorScheme colorScheme, TaskSummaryStats stats) {
    final textStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    );

    if (stats.mode == SubtaskMode.shared) {
      // Show completed/total ratio
      return Text(
        "${stats.completedSubtasks}/${stats.totalSubtasks}",
        textAlign: TextAlign.end,
        style: textStyle,
      );
    } else {
      // Show total number of participants
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${stats.totalRespondents}", style: textStyle),
          const SizedBox(width: 2),
          Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
        ],
      );
    }
  }
}