import 'package:checkin_frontend/core/providers/task_providers.dart';
import 'package:checkin_frontend/core/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/subtask_template/subtask_template_create_model.dart';
import '../../../../core/models/subtask_template/subtask_template_list_model.dart';
import '../../../../core/models/subtask_template/subtask_template_update_model.dart';
import '../../data/models/subtask_combined_list_model.dart';

class SubtaskListSection extends ConsumerStatefulWidget {
  final String title;
  final String taskId;
  final List<SubtaskCombinedListModel> subtasks;

  const SubtaskListSection({
    super.key,
    required this.title,
    required this.taskId,
    required this.subtasks,
  });

  @override
  ConsumerState<SubtaskListSection> createState() => _SubtaskListSectionState();
}

class _SubtaskListSectionState extends ConsumerState<SubtaskListSection> {
  bool _isEditMode = false;
  bool _isAddingNew = false;

  final _newTitleController = TextEditingController();
  final _newDescController = TextEditingController();

  @override
  void dispose() {
    _newTitleController.dispose();
    _newDescController.dispose();
    super.dispose();
  }

  // API VOLANIA
  Future<void> _addTemplate() async {
    if (_newTitleController.text.trim().isEmpty) return;
    try {
      final model = SubtaskTemplateCreateModel(
        title: _newTitleController.text.trim(),
        description: _newDescController.text.trim(),
        parentTaskId: widget.taskId,
      );
      await ref.read(subtaskTemplateApiServiceProvider).createTemplate(model);

      setState(() {
        _isAddingNew = false;
        _newTitleController.clear();
        _newDescController.clear();
      });
      AppSnackBar.showSuccess(context, "Subtask added successfully");
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to add subtask: $e");
    }
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await ref.read(subtaskTemplateApiServiceProvider).deleteTemplate(id);
      AppSnackBar.showSuccess(context, "Subtask deleted");
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to delete: $e");
    }
  }

  Future<void> _updateTemplate(String id, {String? title, String? desc}) async {
    try {
      final model = SubtaskTemplateUpdateModel(id: id, title: title ?? "", description: desc);
      await ref.read(subtaskTemplateApiServiceProvider).updateTemplate(id, model);
      AppSnackBar.showSuccess(context, "Changes saved");
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SelectionArea( // Obalíme celú sekciu tu, aby bol text kopírovateľný globálne
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HLAVIČKA SEKCIE
          Row(
            children: [
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(width: 12), // Medzera medzi titulom a tlačidlami
              if (!_isEditMode)
                TextButton.icon(
                  onPressed: () => setState(() => _isEditMode = true),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"), // Zmenené z Edit structure na Edit
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                )
              else ...[
                TextButton.icon(
                  onPressed: () => setState(() => _isAddingNew = true),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add"),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _isEditMode = false;
                    _isAddingNew = false;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save"),
                ),
              ],
              const Spacer(), // Spacer je teraz na konci, aby tlačidlá boli vľavo
            ],
          ),
          const SizedBox(height: 12),

          if (_isAddingNew) _buildNewSubtaskInput(cs),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.subtasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final subtask = widget.subtasks[index];
              return _buildSubtaskItem(subtask, cs);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(SubtaskCombinedListModel subtask, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), // Väčšia medzera medzi kartami
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: _InlineEditableText(
          isEditMode: _isEditMode,
          initialValue: subtask.title,
          hintText: "Title is required",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          onSave: (val) =>
              _updateTemplate(subtask.templateSubtaskId, title: val, desc: subtask.description),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _InlineEditableText(
            isEditMode: _isEditMode,
            initialValue: subtask.description ?? "",
            hintText: "Add a description...",
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            onSave: (val) =>
                _updateTemplate(subtask.templateSubtaskId, title: subtask.title, desc: val),
          ),
        ),
        trailing: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: () => _deleteTemplate(subtask.templateSubtaskId),
              )
            : null,
      ),
    );
  }

  Widget _buildNewSubtaskInput(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Jemne zvýraznené pozadie, aby bolo jasné, že ide o nový záznam
        color: cs.primaryContainer.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withAlpha(80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "NEW SUBTASK",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: cs.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          // TITLE INPUT
          TextField(
            controller: _newTitleController,
            autofocus: true,
            maxLength: 255,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "What needs to be done?",
              isDense: true,
              filled: true,
              fillColor: cs.surface,
              counterText: _newTitleController.text.length > 200 ? null : "",
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
            // Po stlačení Enter v Title preskočí na Description
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 12),

          // DESCRIPTION INPUT
          TextField(
            controller: _newDescController,
            maxLength: 255,
            maxLines: null,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            decoration: InputDecoration(
              hintText: "Add more details (optional)...",
              isDense: true,
              filled: true,
              fillColor: cs.surface,
              counterText: _newDescController.text.length > 200 ? null : "",
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
            // Enter v popise rovno odošle (uloží) subtask
            onSubmitted: (_) => _addTemplate(),
          ),
          const SizedBox(height: 12),

          // AKCIE
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _isAddingNew = false;
                  _newTitleController.clear();
                  _newDescController.clear();
                }),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addTemplate,
                icon: const Icon(Icons.check, size: 18),
                label: const Text("Add Subtask"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineEditableText extends StatefulWidget {
  final String initialValue;
  final TextStyle style;
  final Function(String) onSave;
  final String? hintText;
  final bool isEditMode;

  const _InlineEditableText({
    required this.initialValue,
    required this.style,
    required this.onSave,
    this.isEditMode = false,
    this.hintText,
  });

  @override
  State<_InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<_InlineEditableText> {
  bool _editing = false;
  bool _hovering = false;
  late TextEditingController _ctrl;
  final int _maxChars = 255;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() { if (_editing) setState(() {}); });
  }

  // KĽÚČOVÁ OPRAVA BUGU: Ak rodič vypne edit mode, musíme vypnúť lokálnu editáciu
  @override
  void didUpdateWidget(_InlineEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditMode && !widget.isEditMode) {
      _editing = false;
      _ctrl.text = widget.initialValue; // Reset textu na pôvodný, ak user neuložil
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().isNotEmpty) {
      widget.onSave(_ctrl.text.trim());
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_editing && widget.isEditMode) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          style: widget.style,
          maxLength: 255,
          maxLines: null,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.all(12),
            counterText: _ctrl.text.length > 200 ? null : "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _submit,
            ),
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.isEditMode ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // Dôležité: kliknutie zachytí celú plochu
        onTap: widget.isEditMode ? () => setState(() => _editing = true) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: widget.isEditMode
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.isEditMode && _hovering
                ? cs.primary.withAlpha(20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isEditMode
                  ? (_hovering ? cs.primary : cs.outlineVariant.withAlpha(100))
                  : Colors.transparent,
            ),
          ),
          // TU UŽ NIE JE SelectionArea, aby nekazila gestá.
          // Výber textu rieši SelectionArea nad celým ListView.
          child: Text(
            widget.initialValue.isEmpty ? (widget.hintText ?? "Edit...") : widget.initialValue,
            style: widget.initialValue.isEmpty
                ? widget.style.copyWith(color: cs.onSurfaceVariant.withAlpha(150), fontStyle: FontStyle.italic)
                : widget.style,
          ),
        ),
      ),
    );
  }
}