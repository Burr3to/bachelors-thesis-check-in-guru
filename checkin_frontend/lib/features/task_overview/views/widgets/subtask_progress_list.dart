import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../data/models/subtask_combined_list_model.dart';

class SubtaskProgressList extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks;
  final List<SubtaskCombinedListModel> templates;
  final SubtaskMode subtaskMode;

  const SubtaskProgressList({
    super.key,
    required this.subtasks,
    required this.templates,
    required this.subtaskMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (subtasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
              context.l10n.overview_progress_empty,
              style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant)
          ),
        ),
      );
    }

    if (subtaskMode == SubtaskMode.individual) {
      return _buildIndividualGroupedList(context, colorScheme);
    } else {
      return _buildSharedList(context, colorScheme);
    }
  }

  Widget _buildSharedList(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: subtasks.map((subtask) => _buildSubtaskCard(context, colorScheme, subtask)).toList(),
    );
  }

  Widget _buildIndividualGroupedList(BuildContext context, ColorScheme colorScheme) {
    final grouped = groupBy(subtasks, (s) => s.responseGroupId);
    final int totalTaskCount = templates.length;

    return Column(
      children: grouped.entries.map((entry) {
        final userInstances = entry.value;
        final firstInstanceWithName = userInstances.firstWhereOrNull((s) => s.respondentName != null);
        final respondentName = firstInstanceWithName?.respondentName ?? context.l10n.overview_progress_not_started;
        final bool isAuthenticatedUser = userInstances.any((s) => s.completedByUserId != null);
        final completedCount = userInstances.where((s) => s.isCompleted).length;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER BOX (Modrastý nádych)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(respondentName, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    if (isAuthenticatedUser) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified_user_outlined, color: Colors.green.shade400, size: 18),
                    ],
                    const Spacer(),
                    Text(
                      context.l10n.overview_progress_completed_count(completedCount, totalTaskCount),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: userInstances.map((s) => _buildUserSubtaskRow(colorScheme, s)).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserSubtaskRow(ColorScheme colorScheme, SubtaskCombinedListModel subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(
              Icons.check_circle,
              color: subtask.isCompleted ? Colors.green.shade400 : colorScheme.outline,
              size: 20
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            ),
          ),
          if (subtask.completedAt != null)
            Text(
              DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildSubtaskCard(BuildContext context, ColorScheme colorScheme, SubtaskCombinedListModel subtask) {
    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(
          subtask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: subtask.isCompleted ? Colors.green.shade400 : colorScheme.outline,
        ),
        title: SelectionArea(
            child: Text(subtask.title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500))
        ),
        subtitle: subtask.description != null
            ? SelectionArea(child: Text(subtask.description!, style: TextStyle(color: colorScheme.onSurfaceVariant)))
            : null,
        trailing: subtask.isCompleted ? _buildCompletedTrailing(colorScheme, subtask) : null,
      ),
    );
  }

  Widget _buildCompletedTrailing(ColorScheme colorScheme, SubtaskCombinedListModel subtask) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subtask.completedByUserId != null)
          Icon(Icons.verified_user_outlined, color: Colors.green.shade400, size: 21),
        const SizedBox(width: 4),
        Text(
          subtask.respondentName ?? "Unknown",
          style: TextStyle(color: Colors.green.shade400, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 8),
        if (subtask.completedAt != null)
          Text(
            DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}