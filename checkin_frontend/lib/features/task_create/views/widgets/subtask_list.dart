import 'package:flutter/material.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';

class SubtaskList extends StatelessWidget {
  final List<SubtaskTemplateCreateModel> subtasks;
  final Function(int) onRemove;

  const SubtaskList({
    super.key,
    required this.subtasks,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Ak je zoznam prázdny, nezobrazíme nič (SizedBox.shrink je efektívnejšie ako null)
    if (subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Added Subtasks:",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        Card(
          child: Column(
            children: subtasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subtask = entry.value;

              return Column(
                children: [
                  ListTile(
                    title: Text(subtask.title),
                    subtitle: subtask.description != null
                        ? Text(subtask.description!)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      radius: 14,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onRemove(index),
                      tooltip: "Remove",
                    ),
                  ),
                  // Pridáme čiaru medzi položky, okrem poslednej
                  if (index != subtasks.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}