import 'package:checkin_frontend/core/utils/quill_viewer.dart';
import 'package:checkin_frontend/features/task_list/data/models/task_list_model.dart';
import 'package:checkin_frontend/features/task_list/views/widgets/task_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/quill_utils.dart';

class TaskCard extends StatelessWidget {
  final TaskListModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isOverdue = task.deadLine.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () => context.go('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HORNÝ RIADOK: Deadline + Ikona Módu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDeadlineBadge(cs, context),

                  // Skupina ikoniek na pravej strane
                  Row(
                    children: [
                      // Ikona overenia (vľavo od módu subtaskov)
                      Icon(
                        task.requiresAuthenticationToComplete
                            ? Icons.verified_user
                            : Icons.no_encryption_outlined,
                        size: 19,
                        // Ak je true, použije primary farbu, inak šedú
                        color: task.requiresAuthenticationToComplete
                            ? cs.primary
                            : cs.onSurfaceVariant.withAlpha(125),
                      ),

                      const SizedBox(width: 8), // Medzera medzi ikonkami

                      // Ikona módu (pôvodná)
                      Icon(
                        task.subtaskMode == SubtaskMode.shared ? Icons.groups : Icons.person,
                        size: 19,
                        color: cs.onSurfaceVariant.withAlpha(125),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // STRED: Titul a Popis
              Text(
                task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  task.notes != null
                      ? QuillUtils.toPlainText(task.notes)
                      : context.l10n.tasks_card_no_desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 4),

              // SPODOK: Progres bar
              TaskProgressBar(taskId: task.id),

              const SizedBox(height: 8),
              // Dátum vytvorenia (malým)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "${context.l10n.tasks_card_created}: ${DateFormatter.formatCreatedAt(context, task.createdAt)}",
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant.withAlpha(180)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineBadge(ColorScheme cs, BuildContext context) {
    final state = task.state;

    // Definujeme farbu badge-u podľa stavu
    // Použijeme priamo farby z tvojho enumu, alebo ich jemne upravíme pre Material 3
    final Color baseColor = state.color;

    // M3 štýl: jemné pozadie, výrazný text
    final Color bgColor = baseColor.withOpacity(0.15);
    final Color contentColor = baseColor;

    // Ikona sa zmení na "fajku", ak je hotovo
    final IconData statusIcon = state == TaskState.completed
        ? Icons.check_circle_outline
        : Icons.alarm;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contentColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: contentColor),
          const SizedBox(width: 6),
          Text(
            // Ak je Completed, môžeme napísať "COMPLETED"
            // alebo nechať dátum. Navrhujem:
            state == TaskState.completed
                ? context.l10n.nav_my_tasks.toUpperCase() // alebo len "DONE"
                : DateFormatter.formatRelativeDeadline(context, task.deadLine),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}
