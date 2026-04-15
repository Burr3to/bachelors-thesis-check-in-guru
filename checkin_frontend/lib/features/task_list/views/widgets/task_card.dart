import 'package:checkin_frontend/core/utils/quill_viewer.dart';
import 'package:checkin_frontend/features/task_list/data/models/task_list_model.dart';
import 'package:checkin_frontend/features/task_list/views/widgets/task_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/quill_utils.dart';

class TaskCard extends StatelessWidget {
  final TaskListModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final deadLineFriendly = DateFormatter.formatRelativeDeadline(task.deadLine);
    final now = DateTime.now();
    final isOverdue = task.deadLine.isBefore(now);
    final colorScheme = Theme.of(context).colorScheme;
    final deadlineColor = isOverdue ? Colors.red : colorScheme.onSurfaceVariant;
    final deadlineIconColor = isOverdue ? Colors.red : colorScheme.primary;

    return Card.outlined(
      child: InkWell(
        onTap: () => context.go('/tasks/${task.id}'),
        child: Container(
          // 1. Nastavíme fixnú alebo minimálnu výšku karty
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Zarovná status tag hore
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRow(
                      Icons.alarm,
                      deadlineIconColor,
                      deadLineFriendly,
                      deadlineColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 2. Poznámky s maxLines: 2
                    if (task.notes != null && task.notes!.isNotEmpty)
                      Text(
                        QuillUtils.toPlainText(task.notes),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // 3. Tento Spacer odtlačí všetko pod ním nadol
                    const Spacer(),

                    const SizedBox(height: 12),
                    TaskProgressBar(taskId: task.id),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Pravý stĺpec so statusom
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: task.state.color,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      task.state.label,
                      style: TextStyle(
                          color: task.state.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 12
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pomocná metóda, aby sme nepísali ten istý kód pre riadok dvakrát
  Widget _buildDateRow(IconData icon, Color iconColor, String label, Color labelColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        Text(
          "$label ",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
