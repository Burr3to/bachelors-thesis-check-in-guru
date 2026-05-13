import 'package:checkin_frontend/core/models/task/task_list_model.dart';
import 'package:checkin_frontend/features/task_list/views/widgets/task_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/quill_utils.dart';
import '../../../../core/utils/responsive.dart';

/// A card widget that displays a summary of a task, including its title,
/// description, deadline, and overall progress.
class TaskCard extends StatelessWidget {
  final TaskListModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = context.isMobile;

    // Define the description text style and behavior based on screen size
    Widget descriptionText = Text(
      task.notes != null
          ? QuillUtils.toPlainText(task.notes)
          : context.l10n.tasks_card_no_desc,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: cs.onSurfaceVariant,
        height: 1.4,
        fontSize: isMobile ? 13 : 14,
      ),
      maxLines: isMobile ? 2 : 4,
      overflow: TextOverflow.ellipsis,
    );

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () => context.go('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
            children: [
              // Top Row: Status/Deadline Badge and Mode Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDeadlineBadge(cs, context, isMobile),

                  Row(
                    children: [
                      // Authentication requirement indicator
                      Tooltip(
                        message: task.requiresAuthenticationToComplete
                            ? "Authentication required"
                            : "Anonymous access allowed",
                        child: Icon(
                          task.requiresAuthenticationToComplete
                              ? Icons.verified_user
                              : Icons.no_encryption_outlined,
                          size: isMobile ? 16 : 19,
                          color: task.requiresAuthenticationToComplete
                              ? cs.primary
                              : cs.onSurfaceVariant.withAlpha(125),
                        ),
                      ),

                      SizedBox(width: isMobile ? 6 : 8),

                      // Collaboration mode indicator (Shared vs Individual)
                      Tooltip(
                        message: task.subtaskMode == SubtaskMode.shared
                            ? "Shared Mode"
                            : "Individual Mode",
                        child: Icon(
                          task.subtaskMode == SubtaskMode.shared ? Icons.groups : Icons.person,
                          size: isMobile ? 16 : 19,
                          color: cs.onSurfaceVariant.withAlpha(125),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // Middle: Task Title
              Text(
                task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: isMobile ? 16 : 22,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: isMobile ? 4 : 8),

              // Description section (adjusts layout based on responsiveness)
              if (isMobile)
                descriptionText
              else
                Expanded(child: descriptionText),

              SizedBox(height: isMobile ? 12 : 16),

              // Bottom: Task Progress Bar Component
              TaskProgressBar(taskId: task.id),

              SizedBox(height: isMobile ? 6 : 8),

              // Creation date timestamp
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "${context.l10n.tasks_card_created}: ${DateFormatter.formatCreatedAt(context, task.createdAt)}",
                  style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: cs.onSurfaceVariant.withAlpha(isMobile ? 140 : 180)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a colored badge indicating the current task state (Deadline or Finished).
  Widget _buildDeadlineBadge(ColorScheme cs, BuildContext context, bool isMobile) {
    final state = task.state;
    final Color baseColor = state.color;
    final Color bgColor = baseColor.withAlpha(38);
    final Color contentColor = baseColor;

    final IconData statusIcon = state == TaskState.completed
        ? Icons.check_circle_outline
        : Icons.alarm;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 4 : 6
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
        border: Border.all(color: contentColor.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: isMobile ? 12 : 14, color: contentColor),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            state == TaskState.completed
                ? "Finished"
                : DateFormatter.formatRelativeDeadline(context, task.deadLine),
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}