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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // TITLE TEXTFIELD
        TextField(
          controller: titleController,
          maxLength: 255,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            labelText: "Title *",
            labelStyle: TextStyle(color: cs.onSurfaceVariant),
            floatingLabelStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            hintText: "Enter Task Title",
            hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),

            filled: true,
            fillColor: cs.surfaceContainerLow, // Tvoja svetlomodrá (v Light)

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outline, width: 2), // Tvoj border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // QUILL TOOLBAR
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh, // Grey[100] v Light
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: cs.outline),
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
              // Zabezpečíme, aby ikony v toolbare mali správnu farbu v dark mode
            ),
          ),
        ),

        // QUILL EDITOR
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow, // Tvoja svetlomodrá (v Light)
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: cs.outline),
          ),
          padding: const EdgeInsets.all(12),
          child: QuillEditor.basic(
            controller: quillController,
            config: QuillEditorConfig(
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