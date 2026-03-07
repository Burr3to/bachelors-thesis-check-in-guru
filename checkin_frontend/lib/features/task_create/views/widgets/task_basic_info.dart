import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TaskBasicInfo extends StatelessWidget {
  final TextEditingController titleController;
  final QuillController quillController;

  const TaskBasicInfo({
    super.key,
    required this.titleController,
    required this.quillController,
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

        // QUILL TOOLBAR (Lišta s nástrojmi)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: const Color.fromRGBO(81, 119, 200, 0.5)),
          ),
          child: QuillSimpleToolbar(
            controller: quillController,
            config: const QuillSimpleToolbarConfig(
              toolbarIconAlignment: WrapAlignment.center,

              showSearchButton: false,
              showFontFamily: false,
              showFontSize: false,
              showSubscript: false,
              showStrikeThrough: false,
              showSuperscript: false,
              showColorButton: false,
              showHeaderStyle: false,
              showQuote: false,
              showBackgroundColorButton: false,
              multiRowsDisplay: true,
            ),
          ),
        ),

        // QUILL EDITOR (v11 štýl)
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(100, 130, 255, 0.1),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: const Color.fromRGBO(81, 119, 200, 0.5)),
          ),
          padding: const EdgeInsets.all(12),
          child: QuillEditor.basic(
            controller: quillController,
            config: const QuillEditorConfig(
              placeholder: 'Enter task description',
              autoFocus: false,
              expands: false,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
