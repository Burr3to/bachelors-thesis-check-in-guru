import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/quill_utils.dart';
import '../../../../core/utils/quill_viewer.dart';
// --- IMPORT PRE RESPONSIVE ---
import '../../../../core/utils/responsive.dart';
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return HoverEditableWrapper(
      isEditing: _isEditing,
      initialValue: widget.initialNotes ?? "",
      hintText: context.l10n.overview_notes_empty,
      // Na mobile trošku menší font pre notes
      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, fontSize: isMobile ? 14 : 16),
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
          ? null
          : IgnorePointer(
        child: QuillViewer(jsonText: widget.initialNotes),
      ),
      editChild: Column(
        children:[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
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
                // KĽÚČOVÁ OPRAVA PRE MOBIL - Scroll namiesto zalomenia nad klávesnicou
                multiRowsDisplay: !isMobile,
              ),
            ),
          ),

          Container(
            // Znížená výška editora na mobile
            constraints: BoxConstraints(
                minHeight: isMobile ? 120 : 200,
                maxHeight: isMobile ? 250 : 400
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(10),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(12),
            child: QuillEditor.basic(
              controller: _controller,
              config: QuillEditorConfig(
                placeholder: context.l10n.overview_notes_hint,
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