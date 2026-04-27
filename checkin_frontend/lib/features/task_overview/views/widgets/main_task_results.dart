import 'package:checkin_frontend/core/models/subtask_instance/subtask_instance_list_model.dart';
import 'package:checkin_frontend/features/task_overview/data/models/subtask_combined_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/utils/l10n_extensions.dart';

class MainTaskResults extends StatelessWidget {
  final List<SubtaskCombinedListModel> allInstances; // List<SubtaskCombinedListModel>
  final SubtaskCombinedListModel subtask; // Ten prvý pre prístup k Title/Desc
  final SubtaskMode subtaskMode; // Enum Shared/Individual

  const MainTaskResults({
    super.key,
    required this.allInstances,
    required this.subtask,
    required this.subtaskMode,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrujeme len splnené podpisy
    final completedSignatures = allInstances.where((i) => i.isCompleted).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            context.l10n.overview_results_signatures,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        if (completedSignatures.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(context.l10n.overview_results_empty, style: const TextStyle(fontStyle: FontStyle.italic))),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completedSignatures.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final sig = completedSignatures[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainer,
                    child: const Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  title: Text(
                    context.l10n.overview_results_confirmed,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: _buildCompletedTrailing(sig, context), // Použitie tvojho UI
                );
              },
            ),
          ),
      ],
    );
  }

  // TVOJA UI METÓDA (Integrovná tu)
  Widget _buildCompletedTrailing(dynamic subtask, dynamic context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Row(
            children: [
              if (subtask.completedByUserId != null) ...[
                const Icon(Icons.verified_user_outlined, color: Colors.green, size: 21)
              ],
              const SizedBox(width: 4),
              SelectionArea(
                child: Text(
                  subtask.respondentName ?? context.l10n.common_unknown,
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
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}