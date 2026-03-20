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

    return allStatsAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (err, stack) => const SizedBox.shrink(),
      data: (statsMap) {
        // Vytiahneme štatistiku pre túto konkrétnu kartu
        final stats = statsMap[taskId];

        if (stats == null) return const SizedBox.shrink();

        // Vykreslíme podľa módu
        return _buildProgressBar(stats);
      },
    );
  }

  Widget _buildProgressBar(TaskSummaryStats stats) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.black.withAlpha(100),
                width: 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: _buildSegments(stats),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: _buildRightLabel(stats),
        ),
      ],
    );
  }

  List<Widget> _buildSegments(TaskSummaryStats stats) {
    if (stats.mode == SubtaskMode.shared) {
      final completed = stats.completedSubtasks;
      final total = stats.totalSubtasks;
      final remaining = total - completed;

      return [
        if (completed > 0)
          Expanded(flex: completed, child: Container(color: Colors.green.shade400)),
        if (remaining > 0 || total == 0)
          Expanded(flex: remaining == 0 && total == 0 ? 1 : remaining,
              child: Container(color: Colors.grey.shade100)),
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
              child: Container(color: Colors.grey.shade200)),
      ];
    }
  }

  Widget _buildRightLabel(TaskSummaryStats stats) {
    final textStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.black54,
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
          Icon(Icons.person_outline, size: 12, color: Colors.grey.shade600),
        ],
      );
    }
  }
}
