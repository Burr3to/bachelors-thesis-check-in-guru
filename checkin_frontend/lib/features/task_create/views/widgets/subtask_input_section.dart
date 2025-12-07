import 'package:flutter/material.dart';
import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';

class SubtaskInputSection extends StatefulWidget {
  final Function(SubtaskTemplateCreateModel) onSubtaskAdded;

  // Nové parametre pre Mód
  final SubtaskMode currentMode;
  final Function(Set<SubtaskMode>) onModeChanged;

  const SubtaskInputSection({
    super.key,
    required this.onSubtaskAdded,
    required this.currentMode,
    required this.onModeChanged,
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

    // Pošleme dáta rodičovi
    widget.onSubtaskAdded(subtask);

    // Vyčistíme polia
    _titleCtrl.clear();
    _descCtrl.clear();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, // Zmena na biele
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Subtasks Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          // 1. Prepínač Módu (Tu hore)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SubtaskMode>(
              segments: const [
                ButtonSegment(
                    value: SubtaskMode.shared,
                    label: Text('Shared (One for all)'),
                    icon: Icon(Icons.group_outlined)
                ),
                ButtonSegment(
                    value: SubtaskMode.individual,
                    label: Text('Individual (One for each)'),
                    icon: Icon(Icons.person_outline)
                ),
              ],
              selected: {widget.currentMode},
              onSelectionChanged: widget.onModeChanged,
              style: ButtonStyle(
                // Trochu vizuálneho tuningu
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 2. Inputy pre nový subtask
          const Text("Add New Subtask", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),

          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
                labelText: "Title",
                isDense: true,
                border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
                labelText: "Description (Optional)",
                isDense: true,
                border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon( // Outlined vyzerá tu lepšie
              onPressed: _handleAdd,
              icon: const Icon(Icons.add),
              label: const Text("Add to List"),
            ),
          )
        ],
      ),
    );
  }
}