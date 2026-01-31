import 'package:flutter/material.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';

class SubtaskList extends StatelessWidget {
  final List<SubtaskTemplateCreateModel> subtasks;
  final Function(int) onRemove;

  const SubtaskList({super.key, required this.subtasks, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Subtask list:",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
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
                    tileColor: Colors.white,
                  ),
                  const SizedBox(height: 4)
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
