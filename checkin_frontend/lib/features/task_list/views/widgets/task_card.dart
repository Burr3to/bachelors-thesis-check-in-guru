import 'dart:convert';

import 'package:checkin_frontend/features/task_list/data/models/task_list_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskListModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final deadLine = task.deadLine != null
        ? DateFormat('dd.MM.yyyy').format(task.deadLine.toLocal())
        : 'Bez termínu';

    final createdAt = DateFormat('dd.MM.yyyy').format(task.createdAt.toLocal());

    final now = DateTime.now();

    final isOverdue = task.deadLine.toLocal().isBefore(now);

    final deadlineColor = isOverdue ? Colors.red : Colors.black;
    final deadlineIconColor = isOverdue ? Colors.red : Colors.blue;

    return Card.outlined(
      borderOnForeground: true,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color.fromRGBO(204, 223, 255, 1),
          width: 2
        )
      ),
      child: InkWell(
        onTap: () {
          context.go('/home/task/${task.id}');
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
                      deadLine,
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

                    Text(
                      task.notes ?? "",
                      style: Theme.of(context).textTheme.bodyMedium,
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
                        color: task.status.color,
                        width: 1,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Text(
                      task.status.label,
                      style: TextStyle(color: task.status.color),
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
