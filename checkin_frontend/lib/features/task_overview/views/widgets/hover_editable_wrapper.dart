import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';

/// A wrapper widget that handles switching between a display ("view") state
/// and an interactive "edit" state. It provides hover effects on desktop
/// and constant visual cues on mobile to indicate that the content is editable.
class HoverEditableWrapper extends StatefulWidget {
  final Widget editChild;
  final bool isEditing;
  final VoidCallback onEditTrigger;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  final String initialValue;
  final String? hintText;
  final TextStyle? style;
  final Widget? viewChild;

  const HoverEditableWrapper({
    super.key,
    required this.editChild,
    required this.isEditing,
    required this.onEditTrigger,
    required this.onSave,
    required this.onCancel,
    required this.initialValue,
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
    final isMobile = context.isMobile;

    // STATE 1: EDIT MODE
    // Displays the editor widget along with Save and Cancel actions.
    if (widget.isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.editChild,
          const SizedBox(height: 12),
          // Wrap is used instead of a Row to prevent overflow if button labels are long on narrow screens
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(context.l10n.common_cancel),
              ),
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

    // STATE 2: VIEW MODE
    // Displays the content. On desktop, shows a hover background and edit icon.
    // On mobile, the edit icon remains partially visible as a discovery cue.
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
              // Display either the custom viewChild or a simple Text with an optional hint
              Expanded(
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
              // The edit icon visibility logic:
              // Mobile: Persistent low opacity (0.4) since there is no hover state.
              // Desktop: Visible (0.4) only when hovering.
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: (isMobile || _isHovering) ? 0.4 : 0.0,
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