import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';

// --- IMPORT PRE RESPONSIVE ---
import '../../../../core/utils/responsive.dart';

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
    final isMobile = context.isMobile; // Zistenie, či sme na mobile

    // 1. STAV: EDITÁCIA (Otvorené textové pole)
    if (widget.isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          widget.editChild,
          const SizedBox(height: 12),
          // ZMENA PRE ISTOTU: Namiesto Row použijeme Wrap, ak by na extra úzkom mobile boli preklady tlačidiel príliš dlhé
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children:[
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

    // 2. STAV: ČÍTANIE (Zobrazenie textu s možnosťou kliknutia)
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onEditTrigger, // Na mobile funguje klasické ťuknutie
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
            children:[
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
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                // NAJDÔLEŽITEJŠIA ZMENA:
                // Na desktope ikona nabehne len na hover (_isHovering).
                // Na mobile (kde hover nie je) ikona svieti jemne nonstop (0.4 opacity).
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