import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/quill_viewer.dart';

class TaskHeader extends StatelessWidget {
  final String title;
  final String? notes;
  final DateTime deadline;

  const TaskHeader({super.key, required this.title, this.notes, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final deadlineStr = DateFormat('dd.MM.yyyy').format(deadline.toLocal());
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.errorContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.error.withAlpha(125)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.alarm, size: 16, color: cs.error),
                const SizedBox(width: 6),
                Text(
                  "Deadline: $deadlineStr",
                  style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (notes != null) ...[QuillViewer(jsonText: notes), const SizedBox(height: 24)],
      ],
    );
  }
}
