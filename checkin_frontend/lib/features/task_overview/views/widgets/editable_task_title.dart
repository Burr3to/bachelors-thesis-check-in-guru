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
  Widget build(BuildContext context) {
    return HoverEditableWrapper(
      isEditing: _isEditing,
      onEditTrigger: () => setState(() => _isEditing = true),
      onCancel: () => setState(() {
        _isEditing = false;
        _controller.text = widget.initialTitle;
      }),
      onSave: () {
        widget.onSave(_controller.text);
        setState(() => _isEditing = false);
      },
      viewChild: Text(
        widget.initialTitle,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      editChild: TextField(
        controller: _controller,
        autofocus: true,
        style: Theme.of(context).textTheme.headlineMedium,
        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)),
      ),
    );
  }
}