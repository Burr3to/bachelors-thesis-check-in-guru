import 'package:flutter/material.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';

class SubtaskList extends StatelessWidget {
  final List<SubtaskTemplateCreateModel> subtasks;
  final Function(int) onRemove;

  const SubtaskList({super.key, required this.subtasks, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (subtasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subtask list:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant, // Jemnejšia farba textu (ako pôvodná grey)
          ),
        ),
        const SizedBox(height: 10),

        // Celý zoznam v jednom "kontajneri"
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          // Použijeme surfaceContainer (tvoja myLightBlueBg v light / tmavosivá v dark)
          color: theme.colorScheme.surfaceContainer,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                final isLast = index == subtasks.length - 1;

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        // Modré pozadie prispôsobené téme
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        radius: 14,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary, // Modrý text indexu
                          ),
                        ),
                      ),
                      title: Text(
                        subtask.title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: subtask.description != null
                          ? Text(
                        subtask.description!,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      )
                          : null,
                      trailing: IconButton(
                        // Použitie systémovej error farby pre mazanie
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        onPressed: () => onRemove(index),
                        tooltip: "Remove",
                      ),
                    ),
                    // Oddelovač medzi položkami, okrem poslednej
                    if (!isLast)
                      Divider(
                        indent: 56,
                        endIndent: 16,
                        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}