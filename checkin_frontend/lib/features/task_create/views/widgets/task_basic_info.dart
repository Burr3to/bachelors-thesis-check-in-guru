import 'package:flutter/material.dart';

class TaskBasicInfo extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  const TaskBasicInfo({
    super.key,
    required this.titleController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: "Title *",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descController,
          decoration: const InputDecoration(
            labelText: "Description",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}