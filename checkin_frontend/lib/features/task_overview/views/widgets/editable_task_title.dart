import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'hover_editable_wrapper.dart';

/// A widget that displays the task title and allows for inline editing.
/// It switches between a standard text view and a text input field.
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
    // Initialize the controller with the current task title
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void didUpdateWidget(EditableTaskTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync the local controller if the external title changes while not editing
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
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    // Adjust typography based on the device form factor
    final titleStyle = isMobile
        ? theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    )
        : theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    return HoverEditableWrapper(
      isEditing: _isEditing,
      initialValue: widget.initialTitle,
      style: titleStyle,
      onEditTrigger: () => setState(() => _isEditing = true),
      onCancel: () => setState(() {
        _isEditing = false;
        _controller.text = widget.initialTitle;
      }),
      onSave: () {
        // Only save if the title is not empty
        if (_controller.text.trim().isNotEmpty) {
          widget.onSave(_controller.text.trim());
          setState(() => _isEditing = false);
        }
      },
      viewChild: Text(
        widget.initialTitle,
        style: titleStyle,
      ),
      editChild: TextField(
        controller: _controller,
        autofocus: true,
        selectAllOnFocus: false,
        style: titleStyle,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
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