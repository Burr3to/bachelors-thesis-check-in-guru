import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/subtask_combined_list_model.dart';

class SubtaskProgressList extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks;

  const SubtaskProgressList({super.key, required this.subtasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: subtasks
          .map(
            (subtask) => Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  subtask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: subtask.isCompleted ? Colors.green : Colors.grey,
                ),
                title: SelectionArea(child: Text(subtask.title)),
                subtitle: SelectionArea(child: Text(subtask.description ?? "")),
                trailing: subtask.isCompleted ? _buildCompletedTrailing(subtask) : null,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCompletedTrailing(SubtaskCombinedListModel subtask) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Row(
            children: [
              if (subtask.completedByUserId != null) ...[
                Icon(Icons.verified_user_outlined, color: Colors.green, size: 21)
              ],
              const SizedBox(width: 4),
              SelectionArea(
                child: Text(
                  subtask.respondentName ?? "Unknown",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (subtask.completedAt != null)
          SelectionArea(
            child: Text(
              DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}
