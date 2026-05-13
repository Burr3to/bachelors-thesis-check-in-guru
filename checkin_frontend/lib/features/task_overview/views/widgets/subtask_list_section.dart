import 'dart:math';
import 'package:checkin_frontend/core/providers/task_providers.dart';
import 'package:checkin_frontend/core/shared_widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/subtask_template/subtask_template_create_model.dart';
import '../../../../core/models/subtask_template/subtask_template_update_model.dart';
import '../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../core/utils/responsive.dart';

/// Section widget for managing subtask blueprints (templates).
/// Allows the author to add, edit, or delete the "master" subtasks of a task.
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
  // Local UI state for edit modes and expansion
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

  /// Sends a request to create a new subtask blueprint.
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
      // Invalidate templates to trigger a refresh
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to add subtask");
    }
  }

  /// Removes a specific subtask blueprint and its associated instances.
  Future<void> _deleteTemplate(String id) async {
    try {
      await ref.read(subtaskTemplateApiServiceProvider).deleteTemplate(id);
      ref.invalidate(taskTemplatesProvider(widget.taskId));
    } catch (e) {
      AppSnackBar.showError(context, "Failed to delete");
    }
  }

  /// Updates title or description for an existing subtask blueprint.
  Future<void> _updateTemplate(String id, {String? title, String? desc}) async {
    try {
      final existing = widget.subtasks.firstWhere((s) => s.templateSubtaskId == id);

      final model = SubtaskTemplateUpdateModel(
        id: id,
        title: title ?? existing.title,
        description: desc ?? existing.description,
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
    final isMobile = context.isMobile;

    // Logic for collapsing long lists
    final int totalItems = widget.subtasks.length;
    final int itemsToShow = _isEditMode || _isExpanded ? totalItems : min(3, totalItems);
    final bool hasMore = totalItems > 3 && !_isEditMode;

    return SelectionArea(
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary, width: 0.8),
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, cs, totalItems, isMobile),
            const SizedBox(height: 12),

            // Checklist of subtask templates
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsToShow,
              itemBuilder: (context, index) {
                final subtask = widget.subtasks[index];
                return _SubtaskRow(
                  key: ValueKey(subtask.templateSubtaskId),
                  index: index + 1,
                  subtask: subtask,
                  isEditMode: _isEditMode,
                  onUpdate: _updateTemplate,
                  onDelete: _deleteTemplate,
                  isMobile: isMobile,
                );
              },
            ),

            // Expansion toggle for long checklists
            if (hasMore)
              _TextLinkButton(
                label: _isExpanded ? "Show less" : "Show ${totalItems - 3} more subtasks",
                isExpanded: _isExpanded,
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),

            // Form to add new subtasks, visible only in Edit Mode
            if (_isEditMode) _buildAddSection(cs, isMobile),
          ],
        ),
      ),
    );
  }

  /// Builds the section header with the title and Edit toggle.
  Widget _buildHeader(ThemeData theme, ColorScheme cs, int totalItems, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
              fontSize: isMobile ? 18 : null,
            ),
          ),
        ),
        const SizedBox(width: 8),

        _HeaderEditButton(
          isEditMode: _isEditMode,
          onPressed: () => setState(() {
            _isEditMode = !_isEditMode;
            if (_isEditMode) _isExpanded = true;
          }),
        ),

        if (!isMobile) ...[
          const SizedBox(width: 12),
          Text(
            "$totalItems ${totalItems == 1 ? 'item' : 'items'}",
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  /// Builds the inline form for adding a new subtask blueprint.
  Widget _buildAddSection(ColorScheme cs, bool isMobile) {
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
            padding: EdgeInsets.all(isMobile ? 10 : 12),
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
                  onSubmitted: (_) => _addTemplate(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newDescController,
                  decoration: _inputDeco(context, "Description (optional)"),
                  onSubmitted: (_) => _addTemplate(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        _isAddingNew = false;
                        _newTitleController.clear();
                        _newDescController.clear();
                      }),
                      style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
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
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Standard decoration for subtask text inputs.
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

/// Toggle button used in the section header to switch management mode.
class _HeaderEditButton extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onPressed;

  const _HeaderEditButton({required this.isEditMode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(isEditMode ? Icons.check : Icons.edit_outlined, size: 16),
      label: Text(isEditMode ? "Done" : "Edit"),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.onPrimary,
        foregroundColor: cs.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      ),
    );
  }
}

/// A row displaying a single subtask template with inline editing support.
class _SubtaskRow extends StatefulWidget {
  final int index;
  final SubtaskCombinedListModel subtask;
  final bool isEditMode;
  final bool isMobile;
  final Function(String, {String? title, String? desc}) onUpdate;
  final Function(String) onDelete;

  const _SubtaskRow({
    super.key,
    required this.index,
    required this.subtask,
    required this.isEditMode,
    required this.onUpdate,
    required this.onDelete,
    required this.isMobile,
  });

  @override
  State<_SubtaskRow> createState() => _SubtaskRowState();
}

class _SubtaskRowState extends State<_SubtaskRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.isEditMode ? () {} : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? cs.primary.withAlpha(15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InlineInput(
                      initialValue: widget.subtask.title,
                      isEditMode: widget.isEditMode,
                      placeholder: "Enter title...",
                      isMobile: widget.isMobile,
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
                      isMobile: widget.isMobile,
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

/// A specialized widget that acts as text when viewed and a TextField when tapped (in Edit Mode).
class _InlineInput extends StatefulWidget {
  final String initialValue;
  final String? placeholder;
  final bool isEditMode;
  final bool isDescription;
  final bool isMobile;
  final TextStyle style;
  final Function(String) onSave;

  const _InlineInput({
    required this.initialValue,
    this.placeholder,
    required this.isEditMode,
    this.isDescription = false,
    required this.isMobile,
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
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  /// Finalizes the edit and propagates the change.
  void _handleSave() {
    if (!_isEditing) return;
    setState(() => _isEditing = false);
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

    // Displays placeholder or value with visual cues for interactivity
    final bool isEmpty = widget.initialValue.isEmpty;
    final bool isHighlighted = _isHovered || (widget.isMobile && isEmpty);

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
            isEmpty ? (widget.placeholder ?? "") : widget.initialValue,
            style: widget.style.copyWith(
              color: isEmpty
                  ? (isHighlighted ? cs.primary : cs.onSurfaceVariant.withAlpha(110))
                  : (isHighlighted ? cs.primary : widget.style.color),
              fontWeight: isEmpty ? FontWeight.w300 : widget.style.fontWeight,
              fontStyle: isEmpty ? FontStyle.italic : null,
              decoration: (widget.isMobile && isEmpty)
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: cs.primary.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple delete icon button for subtask rows.
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

/// Centered text button used for expanding/collapsing the subtask list.
class _TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isExpanded;

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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Trigger widget that opens the "Add New Subtask" input form.
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