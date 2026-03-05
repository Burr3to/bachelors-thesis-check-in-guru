import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // Pridaj do pubspec.yaml alebo použi manuálne zoskupenie
import '../../data/models/subtask_combined_list_model.dart';

class SubtaskProgressList extends StatelessWidget {
  final List<SubtaskCombinedListModel> subtasks;
  final List<SubtaskCombinedListModel> templates; // PRIDANÉ
  final SubtaskMode subtaskMode; // Pridaný parameter

  const SubtaskProgressList({
    super.key,
    required this.subtasks,
    required this.templates, // Vyžadujeme šablóny
    required this.subtaskMode,
  });

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No progress recorded yet.", style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      );
    }

    // ROZHODOVANIE PODĽA MÓDU
    if (subtaskMode == SubtaskMode.individual) {
      return _buildIndividualGroupedList();
    } else {
      return _buildSharedList();
    }
  }

  // --- 1. SHARED LIST (Pôvodné UI) ---
  Widget _buildSharedList() {
    return Column(
      children: subtasks.map((subtask) => _buildSubtaskCard(subtask)).toList(),
    );
  }

  // --- 2. INDIVIDUAL LIST (Zoskupené podľa užívateľa) ---
  Widget _buildIndividualGroupedList() {
    final grouped = groupBy(subtasks, (s) => s.respondentName ?? "Unknown");

    // Celkový počet úloh, ktoré MALI BYŤ splnené
    final int totalTaskCount = templates.length;

    return Column(
      children: grouped.entries.map((entry) {
        final respondentName = entry.key;
        final userInstances = entry.value;
        final bool isAuthenticatedUser = userInstances.any((s) => s.completedByUserId != null);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blueAccent.withAlpha(25),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(respondentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (isAuthenticatedUser) ...[
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: "Authenticated User",
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      "${userInstances.length}/$totalTaskCount Completed",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: userInstances.map((s) => _buildUserSubtaskRow(s)).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Jeden riadok v rámci užívateľského bloku (Individual)
  Widget _buildUserSubtaskRow(SubtaskCombinedListModel subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Spacer(),
          if (subtask.completedAt != null)
            Text(
              DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal()),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
        ],
      ),
    );
  }

  // Pôvodná karta pre Shared mód
  Widget _buildSubtaskCard(SubtaskCombinedListModel subtask) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          subtask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: subtask.isCompleted ? Colors.green : Colors.grey,
        ),
        title: SelectionArea(child: Text(subtask.title)),
        subtitle: subtask.description != null ? SelectionArea(child: Text(subtask.description!)) : null,
        trailing: subtask.isCompleted ? _buildCompletedTrailing(subtask) : null,
      ),
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
              if (subtask.completedByUserId != null)
                const Icon(Icons.verified_user_outlined, color: Colors.green, size: 21),
              const SizedBox(width: 4),
              SelectionArea(
                child: Text(
                  subtask.respondentName ?? "Unknown",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
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
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}