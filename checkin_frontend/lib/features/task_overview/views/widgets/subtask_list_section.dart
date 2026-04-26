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
      // Refresh rieši SignalR z backendu, ale pre istotu:
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to add subtask: $e");
    }
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await ref.read(subtaskTemplateApiServiceProvider).deleteTemplate(id);
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to delete: $e");
    }
  }

  Future<void> _updateTemplate(String id, {String? title, String? desc}) async {
    try {
      final model = SubtaskTemplateUpdateModel(id: id, title: title ?? "", description: desc);
      await ref.read(subtaskTemplateApiServiceProvider).updateTemplate(id, model);
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HLAVIČKA SEKCIE S TLAČIDLAMI
        Row(
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Spacer(),
            if (!_isEditMode)
              TextButton.icon(
                onPressed: () => setState(() => _isEditMode = true),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit structure"),
              )
            else ...[
              TextButton(
                onPressed: () => setState(() => _isAddingNew = true),
                child: const Text("Add new"),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _isEditMode = false;
                  _isAddingNew = false;
                }),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // INPUT PRE NOVÝ SUBTASK (Zobrazí sa len pri "Add new")
        if (_isAddingNew) _buildNewSubtaskInput(cs),

        // ZOZNAM SUBTASKU
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
    );
  }

  Widget _buildSubtaskItem(SubtaskCombinedListModel subtask, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant.withAlpha(125)),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        // EDITÁCIA TITLE CEZ WRAPPER
        title: _isEditMode
            ? _InlineEditableText(
                initialValue: subtask.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                onSave: (val) => _updateTemplate(subtask.templateSubtaskId, title: val, desc: subtask.description),
              )
            : Text(
                subtask.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),

        // EDITÁCIA DESCRIPTION
        subtitle: subtask.description != null || _isEditMode
            ? _isEditMode
                  ? _InlineEditableText(
                      initialValue: subtask.description ?? "",
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      hintText: "Add description...",
                      onSave: (val) => _updateTemplate(subtask.templateSubtaskId, title: subtask.title, desc: val),
                    )
                  : Text(
                      subtask.description!,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    )
            : null,

        trailing: _isEditMode
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _deleteTemplate(subtask.templateSubtaskId),
              )
            : null,
      ),
    );
  }

  Widget _buildNewSubtaskInput(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withAlpha(100)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _newTitleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Subtask title", isDense: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newDescController,
            decoration: const InputDecoration(hintText: "Description (optional)", isDense: true),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isAddingNew = false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(onPressed: _addTemplate, child: const Text("Add")),
            ],
          ),
        ],
      ),
    );
  }
}

// POMOCNÝ INTERNÝ WIDGET PRE INLINE EDITÁCIU (aby sme nemuseli duplikovať logiku HoverEditableWrapperu)
class _InlineEditableText extends StatefulWidget {
  final String initialValue;
  final TextStyle style;
  final Function(String) onSave;
  final String? hintText;

  const _InlineEditableText({
    required this.initialValue,
    required this.style,
    required this.onSave,
    this.hintText,
  });

  @override
  State<_InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<_InlineEditableText> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return TextField(
        controller: _ctrl,
        autofocus: true,
        style: widget.style,
        decoration: InputDecoration(isDense: true, hintText: widget.hintText),
        onSubmitted: (val) {
          widget.onSave(val);
          setState(() => _editing = false);
        },
      );
    }

    return InkWell(
      onTap: () => setState(() => _editing = true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent), // Aby neposkočilo pri hover
        ),
        child: Text(
          widget.initialValue.isEmpty ? (widget.hintText ?? "Edit...") : widget.initialValue,
          style: widget.initialValue.isEmpty
              ? widget.style.copyWith(color: Colors.grey, fontStyle: FontStyle.italic)
              : widget.style,
        ),
      ),
    );
  }
}
