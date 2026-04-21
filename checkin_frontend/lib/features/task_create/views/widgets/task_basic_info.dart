import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TaskBasicInfo extends StatefulWidget {
  final TextEditingController titleController;
  final QuillController quillController;

  const TaskBasicInfo({super.key, required this.titleController, required this.quillController});

  @override
  State<TaskBasicInfo> createState() => _TaskBasicInfoState();
}

class _TaskBasicInfoState extends State<TaskBasicInfo> {
  final FocusNode _editorFocusNode = FocusNode();

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          // TITLE TEXTFIELD
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: TextField(
              controller: widget.titleController,
              maxLength: 255,
              style: TextStyle(color: cs.onSurface),
              textInputAction: TextInputAction.next,
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
          ),
      
          const SizedBox(height: 16),
      
          // QUILL TOOLBAR
          ExcludeFocus(
            excluding: true, // Toto spôsobí, že Tab preskočí všetky ikony v lište
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: cs.outline),
              ),
              child: QuillSimpleToolbar(
                controller: widget.quillController,
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
          ),
      
          // QUILL EDITOR
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: Container(
              constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow, // Tvoja svetlomodrá (v Light)
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: cs.outline),
              ),
              padding: const EdgeInsets.all(12),
              child: QuillEditor.basic(
                controller: widget.quillController,
                focusNode: _editorFocusNode,
                config: QuillEditorConfig(
                  placeholder: 'Enter task description',
                  customStyles: DefaultStyles(
                    // Paragraph
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const BoxDecoration(),
                    ),
                    // Placeholder
                    placeHolder: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                      ),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      const BoxDecoration(),
                    ),
                  ),
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
