import 'package:checkin_frontend/core/models/subtask_instance/subtask_combined_list_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';

/// A card widget displaying a list of subtasks for the response view.
/// It distinguishes between completed items and interactive checkboxes for pending work.
class SubtaskListCard extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks;
  final Set<String> selectedIds;
  final Function(String, bool) onSelectionChanged;

  const SubtaskListCard({
    super.key,
    required this.subtasks,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Filter out templates generated automatically from the main task
    // unless it's the only item present.
    final visibleSubtasks = subtasks
        .where((s) => !s.isGeneratedFromTask || subtasks.length == 1)
        .toList();

    return Card(
      color: cs.surfaceContainer,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleSubtasks.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, indent: 16, endIndent: 16, color: cs.outlineVariant),
        itemBuilder: (context, index) {
          final subtask = visibleSubtasks[index];

          final isDone = subtask.isCompleted;
          // Determine if the subtask was finished after the deadline
          final isLate = isDone && subtask.completedAt != null && subtask.completedAt!.isAfter(subtask.deadline);
          // Determine if the item is still pending and already past its deadline
          final isOverdue = !isDone && DateTime.now().isAfter(subtask.deadline);

          final bool hasDescription = subtask.description != null && subtask.description!.trim().isNotEmpty;

          // Adjust padding for mobile devices
          final contentPadding = EdgeInsets.symmetric(
            horizontal: context.isMobile ? 8.0 : 16.0,
            vertical: context.isMobile ? 4.0 : 8.0,
          );

          // Render a informative tile for already completed subtasks
          if (isDone) {
            // Apply distinct visual feedback for late completions
            final statusColor = isLate ? cs.error : Colors.green;
            final statusIcon = isLate ? Icons.alarm_off : Icons.check_circle;

            final String respondentText = subtask.respondentName ?? context.l10n.common_unknown;
            final String subtitleText = isLate
                ? "Completed after deadline ($respondentText)"
                : context.l10n.respond_completed_by(respondentText);

            return ListTile(
              contentPadding: contentPadding,
              leading: Icon(statusIcon, color: statusColor),
              title: Text(
                subtask.title,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(
                subtitleText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          // Render an interactive checkbox for pending items
          return CheckboxListTile(
            contentPadding: contentPadding,
            value: selectedIds.contains(subtask.id),
            onChanged: (val) => onSelectionChanged(subtask.id, val ?? false),
            title: Text(
              subtask.title,
              // Highlight pending subtasks in red if they are overdue
              style: TextStyle(
                color: isOverdue ? cs.error : cs.onSurface,
                fontSize: context.isMobile ? 14 : 16,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: hasDescription
                ? Text(
              subtask.description!,
              style: TextStyle(color: cs.onSurfaceVariant),
            )
                : null,
            activeColor: cs.primary,
            controlAffinity: ListTileControlAffinity.leading,
            isThreeLine: false,
          );
        },
      ),
    );
  }
}