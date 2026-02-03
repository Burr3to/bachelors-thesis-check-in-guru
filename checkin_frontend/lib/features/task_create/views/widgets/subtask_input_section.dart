import 'package:checkin_frontend/features/task_create/views/widgets/app_toggle_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/models/subtask_template/subtask_template_create_model.dart';

class SubtaskInputSection extends StatefulWidget {
  final Function(SubtaskTemplateCreateModel) onSubtaskAdded;

  const SubtaskInputSection({
    super.key,
    required this.onSubtaskAdded,
  });

  @override
  State<SubtaskInputSection> createState() => _SubtaskInputSectionState();
}

class _SubtaskInputSectionState extends State<SubtaskInputSection> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _handleAdd() {
    if (_titleCtrl.text.isEmpty) return;
    final subtask = SubtaskTemplateCreateModel(
      title: _titleCtrl.text,
      description: _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
    );
    widget.onSubtaskAdded(subtask);
    _titleCtrl.clear();
    _descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        const Text("Subtask", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        // Title TextField
        TextField(
          controller: _titleCtrl,
          decoration: _buildInputDecoration("Title", "Enter subtask title.."),
        ),

        const SizedBox(height: 12),

        // Description TextField
        TextField(
          controller: _descCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: _buildInputDecoration("Description", "Enter subtask description.."),
        ),

        const SizedBox(height: 12),

        // Add Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleAdd,
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            label: const Text("Add to List", style: TextStyle(color: Colors.blueAccent)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              side: const BorderSide(color: Colors.blueAccent, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  // Pomocná metóda, aby si nemusel duplikovať kód dekorácie pre oba TextFieldy
  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Colors.blue),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromRGBO(81, 119, 200, 0.3), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }
}