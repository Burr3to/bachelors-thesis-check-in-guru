// ignore_for_file: unused_import

import 'package:checkin_frontend/features/task_create/views/widgets/app_toggle_button.dart';
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
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        Text(
            "Subtask",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface, // Dynamická farba textu
            )
        ),
        const SizedBox(height: 10),

        // Title TextField
        TextField(
          controller: _titleCtrl,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: _buildInputDecoration(context, "Title", "Enter subtask title.."),
        ),

        const SizedBox(height: 12),

        // Description TextField
        TextField(
          controller: _descCtrl,
          style: TextStyle(color: theme.colorScheme.onSurface),
          minLines: 2,
          maxLines: 4,
          decoration: _buildInputDecoration(context, "Description", "Enter subtask description.."),
        ),

        const SizedBox(height: 16),

        // Add Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleAdd,
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            label: Text(
                "Add to List",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )
            ),
            style: OutlinedButton.styleFrom(
              // V light mode biela, v dark mode tmavá 'surface'
              backgroundColor: theme.colorScheme.surface,
              minimumSize: const Size(0, 52),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: theme.colorScheme.primary, // efekt vlny pri stlačení
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }

  // Pomocná metóda prerobená na podporu témy
  InputDecoration _buildInputDecoration(BuildContext context, String label, String hint) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      // 'onSurfaceVariant' je v light móde black54 a v dark white70
      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
      filled: true,
      // 'surfaceContainer' zabezpečí, že inputy budú jemne odlíšené od pozadia
      fillColor: theme.colorScheme.surfaceContainer,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      // Neaktívny border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 2,
        ),
      ),

      // Aktívny (zaostrený) border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}