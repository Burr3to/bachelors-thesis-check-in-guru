import 'package:flutter/material.dart';
import 'hover_editable_wrapper.dart';

class EditableTaskTitle extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSave;

  const EditableTaskTitle({super.key, required this.initialTitle, required this.onSave});

  @override
  State<EditableTaskTitle> createState() => _EditableTaskTitleState();
}

class _EditableTaskTitleState extends State<EditableTaskTitle> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void didUpdateWidget(EditableTaskTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTitle != widget.initialTitle && !_isEditing) {
      _controller.text = widget.initialTitle;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TENTO RIADOK CHÝBAL:
    final theme = Theme.of(context);

    return HoverEditableWrapper(
      isEditing: _isEditing,
      initialValue: widget.initialTitle,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      onEditTrigger: () => setState(() => _isEditing = true),
      onCancel: () => setState(() {
        _isEditing = false;
        _controller.text = widget.initialTitle;
      }),
      onSave: () {
        if (_controller.text.trim().isNotEmpty) {
          widget.onSave(_controller.text.trim());
          setState(() => _isEditing = false);
        }
      },
      // Kedže HoverEditableWrapper teraz generuje Text interne,
      // viewChild môžeme nechať null alebo ho zladiť
      viewChild: Text(
        widget.initialTitle,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      editChild: TextField(
        controller: _controller,
        autofocus: true,
        selectAllOnFocus: false,
        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(12),
          // Skryjeme counter, aby to nebolo príliš vysoké
          counterText: "",
        ),
        maxLength: 255,
        onSubmitted: (val) {
          if (val.trim().isNotEmpty) {
            widget.onSave(val.trim());
            setState(() => _isEditing = false);
          }
        },
      ),
    );
  }
}