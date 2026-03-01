
import 'package:checkin_frontend/core/utils/quill_viewer.dart';
import 'package:checkin_frontend/features/task_list/data/models/task_list_model.dart';
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
    final deadlineColor = isOverdue ? Colors.red : Colors.black87;
    final deadlineIconColor = isOverdue ? Colors.red : Colors.blueAccent;

    return Card.outlined(
      borderOnForeground: true,
        color: Color.fromRGBO(240, 244, 248, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color.fromRGBO(204, 223, 255, 1),
          width: 2
        )
      ),
      child: InkWell(
        onTap: () {
          context.go('/app/tasks/details/${task.id}');
          print("Klikol si na úlohu: ${task.title}");
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 16),
          child: Row(
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

                    const SizedBox(height: 12),

                    Text(
                      task.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    if (task.notes != null && task.notes!.isNotEmpty)
                      Text(
                        QuillUtils.toPlainText(task.notes),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                  ],
                ),
              ),

              const SizedBox(width: 32),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: task.state.color,
                        width: 1,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Text(
                      task.state.label,
                      style: TextStyle(color: task.state.color),
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
