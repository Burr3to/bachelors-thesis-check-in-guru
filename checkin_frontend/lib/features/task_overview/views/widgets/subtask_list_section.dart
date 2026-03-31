import 'package:flutter/material.dart';
import '../../data/models/subtask_combined_list_model.dart';

class SubtaskListSection extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks; // Updated Type
  final String title;

  const SubtaskListSection({super.key, required this.subtasks, required this.title});

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) return const Text("This Task doesn't have any subtasks");
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        ...subtasks.map((subtask) => _buildSubtaskCard(subtask, colorScheme)),
      ],
    );
  }

  Widget _buildSubtaskCard(SubtaskCombinedListModel subtask, final colorScheme) {
    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: SelectionArea(child: Text(subtask.title)), // Now works!
        subtitle: subtask.description != null
            ? SelectionArea(child: Text(subtask.description!, style: TextStyle(color: colorScheme.onSurfaceVariant)))
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      ),
    );
  }
}