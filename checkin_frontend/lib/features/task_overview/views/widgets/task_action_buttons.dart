import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../task_list/data/task_providers.dart';

class TaskActionButtons extends ConsumerWidget {
  final String taskId;
  final String taskLink;
  final VoidCallback onDeleteSuccess; // A callback to tell the parent what to do

  const TaskActionButtons({
    super.key,
    required this.taskId,
    required this.taskLink,
    required this.onDeleteSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => _handleDelete(context, ref),
          label: const Text("Delete", style: TextStyle(color: Colors.red)),
          icon: const Icon(Icons.delete, color: Colors.red),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: Colors.red, width: 1),
          ),
        ),

        const Spacer(),

        OutlinedButton.icon(
          icon: const Icon(Icons.copy, color: Colors.blueAccent),
          label: const Text("Copy link", style: TextStyle(color: Colors.blueAccent)),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: Colors.blueAccent, width: 1),
          ),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: taskLink));

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Copied to clipboard"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskApiServiceProvider).deleteTask(taskId);
      ref.invalidate(taskListProvider);

      onDeleteSuccess();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
