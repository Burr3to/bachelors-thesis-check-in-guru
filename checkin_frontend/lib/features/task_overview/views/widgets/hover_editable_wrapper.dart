import 'package:flutter/material.dart';

class HoverEditableWrapper extends StatefulWidget {
  final Widget viewChild;
  final Widget editChild;
  final bool isEditing;
  final VoidCallback onEditTrigger;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const HoverEditableWrapper({
    super.key,
    required this.viewChild,
    required this.editChild,
    required this.isEditing,
    required this.onEditTrigger,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<HoverEditableWrapper> createState() => _HoverEditableWrapperState();
}

class _HoverEditableWrapperState extends State<HoverEditableWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.editChild,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancel, child: const Text("Cancel")),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(81, 119, 200, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Save Changes"),
              ),
            ],
          )
        ],
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hlavný text - používame SelectionArea, aby sa dal kopírovať
          Expanded(
            child: SelectionArea(
              child: widget.viewChild,
            ),
          ),

          // Malý štvorček s ceruzkou napravo
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isHovering ? 1.0 : 0.0,
              child: InkWell(
                onTap: widget.onEditTrigger,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromRGBO(81, 119, 200, 0.5)),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color.fromRGBO(81, 119, 200, 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}