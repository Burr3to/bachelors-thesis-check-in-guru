import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';

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
    final isMobile = context.isMobile; // Zistenie mobilu

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children:[
          // TITLE TEXTFIELD
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: TextField(
              controller: widget.titleController,
              maxLength: 255,
              style: TextStyle(color: cs.onSurface),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.task_create_basic_title_label,
                labelStyle: TextStyle(color: cs.onSurfaceVariant),
                floatingLabelStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                hintText: context.l10n.task_create_basic_title_hint,
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outline, width: 2),
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
            excluding: true,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: cs.outline),
              ),
              // Ak je to mobil, Toolbar bude scrolovatelný doľava/doprava
              // Ak desktop, bude to zalomené do viacerých riadkov.
              child: QuillSimpleToolbar(
                controller: widget.quillController,
                config: QuillSimpleToolbarConfig( // Odstránený const
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
                  // NAJDÔLEŽITEJŠIA ZMENA PRE MOBIL:
                  multiRowsDisplay: !isMobile,
                ),
              ),
            ),
          ),

          // QUILL EDITOR
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: Container(
              // Menšia výška na mobile, aby klávesnica všetko neprekryla
              constraints: BoxConstraints(
                minHeight: isMobile ? 120 : 200,
                maxHeight: isMobile ? 250 : 400,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: cs.outline),
              ),
              padding: const EdgeInsets.all(12),
              child: QuillEditor.basic(
                controller: widget.quillController,
                focusNode: _editorFocusNode,
                config: QuillEditorConfig(
                  placeholder: context.l10n.task_create_basic_desc_placeholder,
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