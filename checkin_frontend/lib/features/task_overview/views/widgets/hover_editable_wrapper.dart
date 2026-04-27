import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';

class HoverEditableWrapper extends StatefulWidget {
  final Widget editChild;
  final bool isEditing;
  final VoidCallback onEditTrigger;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  // Pridané polia, ktoré chýbali
  final String initialValue;
  final String? hintText;
  final TextStyle? style;
  // Ponecháme voliteľný viewChild pre prípady ako QuillViewer
  final Widget? viewChild;

  const HoverEditableWrapper({
    super.key,
    required this.editChild,
    required this.isEditing,
    required this.onEditTrigger,
    required this.onSave,
    required this.onCancel,
    required this.initialValue, // Povinné pre detekciu prázdnoty
    this.hintText,
    this.style,
    this.viewChild,
  });

  @override
  State<HoverEditableWrapper> createState() => _HoverEditableWrapperState();
}

class _HoverEditableWrapperState extends State<HoverEditableWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.editChild,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(context.l10n.common_cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(context.l10n.overview_btn_save_changes),
              ),
            ],
          )
        ],
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onEditTrigger,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovering ? cs.primary.withAlpha(15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovering ? cs.primary.withAlpha(60) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // Ak máme viewChild (Quill), použijeme ho, inak vykreslíme Text
                child: widget.viewChild ?? Text(
                  widget.initialValue.isEmpty
                      ? (widget.hintText ?? "Edit...")
                      : widget.initialValue,
                  style: widget.initialValue.isEmpty
                      ? widget.style?.copyWith(
                      color: cs.onSurfaceVariant.withAlpha(150),
                      fontStyle: FontStyle.italic
                  )
                      : widget.style,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isHovering ? 0.5 : 0.0,
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}