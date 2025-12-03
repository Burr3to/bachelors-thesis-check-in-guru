import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Nezabudni importovať tvoj model Tasku!
import 'package:checkin_frontend/features/tasks/data/models/task_list_model.dart';

class TaskCard extends StatelessWidget {
  // 1. Definovanie parametra: Tento widget potrebuje "Task" na to, aby fungoval
  final dynamic task; // Zmeň 'dynamic' na tvoj typ, napr. 'TaskDto' alebo 'Task'

  const TaskCard({
    super.key,
    required this.task, // 2. Vynútime si, aby nám ho rodič poslal
  });

  @override
  Widget build(BuildContext context) {
    // 3. Logika formátovania patrí sem, lebo súvisí so zobrazením
    final deadLine = task.deadLine != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(task.deadLine!.toLocal())
        : 'Bez termínu';

    final createdAt = DateFormat('dd.MM.yyyy').format(task.createdAt.toLocal());

    // 4. Vrátime UI (skopírované z tvojho pôvodného kódu)
    return Card(
      elevation: 4,
      // Pridal som InkWell, aby karta reagovala na kliknutie (tap effect)
      child: InkWell(
        onTap: () {
          context.go('/home/task/${task.id}');
          print("Klikol si na úlohu: ${task.title}");
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              _buildDateRow(Icons.alarm, "Deadline:", deadLine, isDeadline: true),

              const Spacer(),
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(), // Vytlačí dátumy naspodok (ak má karta fixnú výšku)

              const Divider(), // Čiara na oddelenie

              // Dátumy
              _buildDateRow(Icons.calendar_today, "Created:", createdAt),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // Pomocná metóda, aby sme nepísali ten istý kód pre riadok dvakrát
  Widget _buildDateRow(IconData icon, String label, String value, {bool isDeadline = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDeadline ? Colors.red : Colors.grey),
        const SizedBox(width: 4),
        Text(
          "$label ",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDeadline ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }
}