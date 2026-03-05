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

    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.alarm, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  "Deadline: $deadlineStr",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (notes != null) ...[
          QuillViewer(jsonText: notes),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
