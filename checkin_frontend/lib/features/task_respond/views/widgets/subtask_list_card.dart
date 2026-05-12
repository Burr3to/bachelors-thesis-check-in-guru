import 'package:checkin_frontend/core/models/subtask_instance/subtask_combined_list_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
// Tvoj nový import pre responzivitu
import '../../../../core/utils/responsive.dart';

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
          final bool hasDescription = subtask.description != null && subtask.description!.trim().isNotEmpty;

          final contentPadding = EdgeInsets.symmetric(
            horizontal: context.isMobile ? 8.0 : 16.0,
            vertical: context.isMobile ? 4.0 : 8.0,
          );

          if (isDone) {
            return ListTile(
              contentPadding: contentPadding,
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
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return CheckboxListTile(
            contentPadding: contentPadding,
            value: selectedIds.contains(subtask.id),
            onChanged: (val) => onSelectionChanged(subtask.id, val ?? false),
            title: Text(
              subtask.title,
              style: TextStyle(color: cs.onSurface, fontSize: context.isMobile ? 14 : 16),
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