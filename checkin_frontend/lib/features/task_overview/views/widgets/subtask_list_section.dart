import 'dart:math';
import 'package:checkin_frontend/core/providers/task_providers.dart';
import 'package:checkin_frontend/core/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/subtask_template/subtask_template_create_model.dart';
import '../../../../core/models/subtask_template/subtask_template_update_model.dart';
import '../../../../core/utils/l10n_extensions.dart';
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
  bool _isExpanded = false;
  bool _isAddingNew = false;

  final _newTitleController = TextEditingController();
  final _newDescController = TextEditingController();

  @override
  void dispose() {
    _newTitleController.dispose();
    _newDescController.dispose();
    super.dispose();
  }

  // --- API ACTIONS ---
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
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to add subtask");
    }
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await ref.read(subtaskTemplateApiServiceProvider).deleteTemplate(id);
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to delete");
    }
  }

  Future<void> _updateTemplate(String id, {String? title, String? desc}) async {
    try {
      // Nájdeme aktuálny subtask v zozname, aby sme vedeli pôvodné hodnoty
      final existing = widget.subtasks.firstWhere((s) => s.templateSubtaskId == id);

      final model = SubtaskTemplateUpdateModel(
        id: id,
        title: title ?? existing.title, // Ak je title null, použi pôvodný
        description: desc ?? existing.description, // Ak je desc null, použi pôvodný
      );

      await ref.read(subtaskTemplateApiServiceProvider).updateTemplate(id, model);
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to update");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final int totalItems = widget.subtasks.length;
    final int itemsToShow = _isEditMode || _isExpanded ? totalItems : min(3, totalItems);
    final bool hasMore = totalItems > 3 && !_isEditMode;

    return SelectionArea(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 1.2),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, cs, totalItems),
            const SizedBox(height: 12),

            // --- LIST ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsToShow,
              itemBuilder: (context, index) {
                final subtask = widget.subtasks[index];
                return _SubtaskRow(
                  // OPRAVA GHOSTINGU: Každý riadok musí mať unikátny kľúč podľa ID databázy
                  key: ValueKey(subtask.templateSubtaskId),
                  index: index + 1,
                  subtask: subtask,
                  isEditMode: _isEditMode,
                  onUpdate: _updateTemplate,
                  onDelete: _deleteTemplate,
                );
              },
            ),

            if (hasMore)
              _TextLinkButton(
                label: _isExpanded ? "Show less" : "Show ${totalItems - 3} more subtasks",
                isExpanded: _isExpanded,
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),

            if (_isEditMode) _buildAddSection(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme cs, int totalItems) {
    return Row(
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        _HeaderEditButton(
          isEditMode: _isEditMode,
          onPressed: () => setState(() {
            _isEditMode = !_isEditMode;
            if (_isEditMode) _isExpanded = true;
          }),
        ),
        const SizedBox(width: 12),
        Text(
          "$totalItems ${totalItems == 1 ? 'item' : 'items'}",
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAddSection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(color: cs.outlineVariant),
        const SizedBox(height: 12),
        if (!_isAddingNew)
          _AddSubtaskTrigger(onPressed: () => setState(() => _isAddingNew = true))
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withAlpha(100)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _newTitleController,
                  autofocus: true,
                  decoration: _inputDeco(context, "Subtask title"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newDescController,
                  decoration: _inputDeco(context, "Description (optional)"),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _addTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Add"),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _isAddingNew = false;
                        _newTitleController.clear();
                        _newDescController.clear();
                      }),
                      style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDeco(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant.withAlpha(150)),
      isDense: true,
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _HeaderEditButton extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onPressed;

  const _HeaderEditButton({required this.isEditMode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(isEditMode ? Icons.check : Icons.edit_outlined, size: 16),
      label: Text(isEditMode ? "Done" : "Edit"),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.onPrimary,
        foregroundColor: cs.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class _SubtaskRow extends StatefulWidget {
  final int index;
  final SubtaskCombinedListModel subtask;
  final bool isEditMode;
  final Function(String, {String? title, String? desc}) onUpdate;
  final Function(String) onDelete;

  const _SubtaskRow({
    super.key,
    required this.index,
    required this.subtask,
    required this.isEditMode,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<_SubtaskRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // OPRAVA 1 & 2: GestureDetector na celom riadku
    return GestureDetector(
      onTap: widget.isEditMode
          ? () {
              // Ak klikne na riadok v edit móde, focusne sa primárne titul (rieši problém s prázdnym textom)
            }
          : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // TU SA NASTAVUJE PADDING MEDZI POLOŽKAMI (vertical: 4)
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? cs.primary.withAlpha(15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Zarovnanie na vrch pri dlhých popisoch
            children: [
              SizedBox(
                width: 24,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "${widget.index}",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12), // MEDZERA MEDZI ČÍSLOM A TEXTOM
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Aby zabral celú šírku pre klikanie
                  children: [
                    _InlineInput(
                      initialValue: widget.subtask.title,
                      isEditMode: widget.isEditMode,
                      placeholder: "Enter title...",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      onSave: (val) =>
                          widget.onUpdate(widget.subtask.templateSubtaskId, title: val),
                    ),
                    _InlineInput(
                      initialValue: widget.subtask.description ?? "",
                      placeholder: "Add description...",
                      isEditMode: widget.isEditMode,
                      isDescription: true,
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant.withAlpha(200)),
                      onSave: (val) => widget.onUpdate(widget.subtask.templateSubtaskId, desc: val),
                    ),
                  ],
                ),
              ),
              if (widget.isEditMode)
                _DeleteIcon(onPressed: () => widget.onDelete(widget.subtask.templateSubtaskId)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineInput extends StatefulWidget {
  final String initialValue;
  final String? placeholder;
  final bool isEditMode;
  final bool isDescription;
  final TextStyle style;
  final Function(String) onSave;

  const _InlineInput({
    required this.initialValue,
    this.placeholder,
    required this.isEditMode,
    this.isDescription = false,
    required this.style,
    required this.onSave,
  });

  @override
  State<_InlineInput> createState() => _InlineInputState();
}

class _InlineInputState extends State<_InlineInput> {
  bool _isEditing = false;
  late TextEditingController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_InlineInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // OPRAVA GHOSTINGU: Ak sa zmenia dáta zvonku, okamžite aktualizujeme controller
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  void _handleSave() {
    if (!_isEditing) return;
    setState(() => _isEditing = false);
    // Uložíme len ak sa hodnota naozaj zmenila
    if (_controller.text != widget.initialValue) {
      widget.onSave(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!widget.isEditMode) {
      if (widget.isDescription && widget.initialValue.isEmpty) return const SizedBox.shrink();
      return Text(
        widget.initialValue,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: widget.style,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            fillColor: cs.primary.withAlpha(20),
            filled: true,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.keyboard_return, size: 14, color: cs.primary.withAlpha(150)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: cs.primary.withAlpha(100)),
            ),
          ),
          onSubmitted: (_) => _handleSave(),
          onTapOutside: (_) => _handleSave(),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _isEditing = true),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            widget.initialValue.isEmpty ? (widget.placeholder ?? "") : widget.initialValue,
            style: widget.style.copyWith(
              // LOGIKA FARBY PLACEHODLERA:
              color: widget.initialValue.isEmpty
                  ? (_isHovered ? cs.primary : cs.onSurfaceVariant.withAlpha(110))
                  : (_isHovered ? cs.primary : widget.style.color),

              // Mierne tenšie písmo pre placeholder, aby nekričalo
              fontWeight: widget.initialValue.isEmpty ? FontWeight.w300 : widget.style.fontWeight,

              // Môžeš nechať alebo odstrániť kurzívu podľa vkusu
              fontStyle: widget.initialValue.isEmpty ? FontStyle.italic : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteIcon extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteIcon({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.delete_outline, size: 18, color: cs.error),
      ),
    );
  }
}

class _TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isExpanded; // Nový parameter

  const _TextLinkButton({required this.label, required this.onPressed, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          foregroundColor: cs.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Vycentrovanie obsahu
          mainAxisSize:
              MainAxisSize.min, // Zaberá len toľko miesta, koľko potrebuje vnútri SizedBoxu
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            // Animovaná ikona šípky
            Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AddSubtaskTrigger extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddSubtaskTrigger({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text("Add subtask", style: TextStyle(fontSize: 14, color: cs.primary)),
          ],
        ),
      ),
    );
  }
}

class _AddSubtaskForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const _AddSubtaskForm({
    required this.titleController,
    required this.descController,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextField(
          controller: titleController,
          autofocus: true,
          decoration: _inputDeco(context, "Subtask title"),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descController,
          decoration: _inputDeco(context, "Description (optional)"),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
              ),
              child: const Text("Add"),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDeco(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: cs.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}
