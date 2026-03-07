import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../../core/utils/quill_utils.dart';
import '../../../../core/utils/quill_viewer.dart';
import 'hover_editable_wrapper.dart';

class EditableTaskNotes extends StatefulWidget {
  final String? initialNotes;
  final Function(String) onSave;

  const EditableTaskNotes({super.key, required this.initialNotes, required this.onSave});

  @override
  State<EditableTaskNotes> createState() => _EditableTaskNotesState();
}

class _EditableTaskNotesState extends State<EditableTaskNotes> {
  bool _isEditing = false;
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = QuillUtils.stringToController(widget.initialNotes);
    _controller.readOnly = false;
  }

  @override
  Widget build(BuildContext context) {
    return HoverEditableWrapper(
      isEditing: _isEditing,
      onEditTrigger: () => setState(() => _isEditing = true),
      onCancel: () {
        setState(() {
          _isEditing = false;
          _initController();
        });
      },
      onSave: () {
        widget.onSave(QuillUtils.controllerToString(_controller));
        setState(() => _isEditing = false);
      },
      viewChild: widget.initialNotes == null || widget.initialNotes!.isEmpty
          ? const Text("No description. Click to add...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
          : QuillViewer(jsonText: widget.initialNotes),

      editChild: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: const Color.fromRGBO(81, 119, 200, 0.5)),
            ),
            child: QuillSimpleToolbar(
              controller: _controller,
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

          Container(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(100, 130, 255, 0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(color: const Color.fromRGBO(81, 119, 200, 0.5)),
            ),
            padding: const EdgeInsets.all(12),
            child: QuillEditor.basic(
              controller: _controller,
              config: const QuillEditorConfig(
                placeholder: 'Enter task description',
                autoFocus: true,
                expands: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}