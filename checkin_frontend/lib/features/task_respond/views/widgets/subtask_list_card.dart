import 'package:checkin_frontend/features/task_overview/data/models/subtask_combined_list_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Tu si doplň správny import pre tvoj model
// import '.../public_task_model.dart';

class SubtaskListCard extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks; // Nahraď správnym typom Subtask
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

    final visibleSubtasks = subtasks.where((s) => !s.isGeneratedFromTask || subtasks.length == 1).toList();

    return Card(
      color: const Color.fromRGBO(240, 244, 248, 1),
      surfaceTintColor: Colors.white,
      child: Column(
        children: visibleSubtasks.asMap().entries.map((entry)  {
          final index = entry.key;
          final subtask = entry.value;
          final isDone = subtask.isCompleted;

          return Column(
            children: [
              if (isDone)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    subtask.title,
                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtask.description != null) Text(subtask.description!),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Completed by: ${subtask.respondentName ?? 'Unknown'}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                            ),
                          ),
                          if (subtask.completedAt != null)
                            Text(
                              DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(subtask.title),
                  subtitle: subtask.description != null ? Text(subtask.description!) : null,
                  value: selectedIds.contains(subtask.id),
                  activeColor: Colors.blue,
                  onChanged: (bool? checked) => onSelectionChanged(subtask.id, checked ?? false),
                ),
              if (index != subtasks.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}