import 'package:checkin_frontend/core/models/Statistics/task_summary_stats.dart';
import 'package:checkin_frontend/core/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/enums/task_enums.dart';

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
        // Vytiahneme štatistiku pre túto konkrétnu kartu
        final stats = statsMap[taskId];

        if (stats == null) return const SizedBox.shrink();

        // Vykreslíme podľa módu
        return _buildProgressBar(context, colorScheme, stats);
      },
    );
  }

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
                color: colorScheme.outlineVariant, // Jemný okraj, ktorý funguje v oboch módoch
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

  List<Widget> _buildSegments(ColorScheme colorScheme, TaskSummaryStats stats) {
    final emptyColor = colorScheme.surfaceContainerHighest;
    if (stats.mode == SubtaskMode.shared) {
      final completed = stats.completedSubtasks;
      final total = stats.totalSubtasks;
      final remaining = total - completed;

      return [
        if (completed > 0)
          Expanded(flex: completed, child: Container(color: Colors.green.shade400)),
        if (remaining > 0 || total == 0)
          Expanded(flex: remaining == 0 && total == 0 ? 1 : remaining,
              child: Container(color: emptyColor)),
      ];
    } else {
      // INDIVIDUAL MODE: Zelená, Oranžová, Sivá
      final total = stats.totalRespondents;
      return [
        if (stats.completedFull > 0)
          Expanded(flex: stats.completedFull, child: Container(color: Colors.green.shade400)),
        if (stats.inProgress > 0)
          Expanded(flex: stats.inProgress, child: Container(color: Colors.orange.shade300)),
        if (stats.notStarted > 0 || total == 0)
          Expanded(flex: stats.notStarted == 0 && total == 0 ? 1 : stats.notStarted,
              child: Container(color: emptyColor)),
      ];
    }
  }

  Widget _buildRightLabel(ColorScheme colorScheme, TaskSummaryStats stats) {
    final textStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
    );

    if (stats.mode == SubtaskMode.shared) {
      return Text(
        "${stats.completedSubtasks}/${stats.totalSubtasks}",
        textAlign: TextAlign.end,
        style: textStyle,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${stats.totalRespondents}", style: textStyle),
          const SizedBox(width: 2),
          Icon(Icons.person_outline, size: 12, color: colorScheme.onSurfaceVariant),
        ],
      );
    }
  }
}
