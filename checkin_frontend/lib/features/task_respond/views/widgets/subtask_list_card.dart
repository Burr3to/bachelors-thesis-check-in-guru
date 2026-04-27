import 'package:checkin_frontend/features/task_overview/data/models/subtask_combined_list_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/l10n_extensions.dart';
// Tu si doplň správny import pre tvoj model
// import '.../public_task_model.dart';

class SubtaskListCard extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks; // Nahraď správnym typom Subtask
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
    final visibleSubtasks = subtasks
        .where((s) => !s.isGeneratedFromTask || subtasks.length == 1)
        .toList();

    return Card(
      color: cs.surfaceContainer,
      elevation: 0,
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

          if (isDone) {
            return ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                subtask.title,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: cs.onSurfaceVariant,
                ),
              ),
              subtitle: Text(
                context.l10n.respond_completed_by(
                  subtask.respondentName ?? context.l10n.common_unknown,
                ),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return CheckboxListTile(
            value: selectedIds.contains(subtask.id),
            onChanged: (val) => onSelectionChanged(subtask.id, val ?? false),
            title: Text(subtask.title, style: TextStyle(color: cs.onSurface)),
            subtitle: subtask.description != null
                ? Text(subtask.description!, style: TextStyle(color: cs.onSurfaceVariant))
                : null,
            activeColor: cs.primary,
            controlAffinity: ListTileControlAffinity.leading,
          );
        },
      ),
    );
  }
}
