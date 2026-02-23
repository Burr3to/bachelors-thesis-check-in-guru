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
          maxLength: 255,

          decoration: InputDecoration(
            //Text
            labelText: "Title *",
            labelStyle: TextStyle(color: Colors.black54),
            floatingLabelStyle: TextStyle(color: Colors.blue),
            hintText: "Enter Task Title",

            //Background
            filled: true,
            fillColor: Color.fromRGBO(100, 130, 255, 0.1),

            //Borders
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color.fromRGBO(81, 119, 200, 0.5), width: 2),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: descController,
          maxLines: null,
          maxLength: 1024,
          minLines: 2,
          keyboardType: TextInputType.multiline,

          decoration: InputDecoration(
            //Text
            labelText: "Description",
            labelStyle: TextStyle(color: Colors.black54),
            floatingLabelStyle: TextStyle(color: Colors.blue),
            hintText: "Enter Task description",

            //Background
            filled: true,
            fillColor: Color.fromRGBO(100, 130, 255, 0.1),

            //Borders
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color.fromRGBO(81, 119, 200, 0.5), width: 2),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
