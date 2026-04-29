import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';

class SubtaskInputSection extends ConsumerStatefulWidget {
  final VoidCallback onRemoveSection;

  const SubtaskInputSection({super.key, required this.onRemoveSection});

  @override
  ConsumerState<SubtaskInputSection> createState() => _SubtaskInputSectionState();
}

class _SubtaskInputSectionState extends ConsumerState<SubtaskInputSection> {
  final _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode(); // Pridaný FocusNode
  final Set<int> _expandedIndices = {};

  void _submitSubtask() {
    if (_inputController.text.trim().isEmpty) return;
    ref.read(taskCreateProvider.notifier).addSubtask(_inputController.text.trim());
    _inputController.clear();
    _inputFocusNode.requestFocus(); // Vráti focus na pole
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subtasks = ref.watch(taskCreateProvider.select((s) => s.subtasks));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.task_create_subtasks_title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              IconButton(
                onPressed: widget.onRemoveSection,
                icon: const Icon(Icons.close, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode, // Priradený focus node
                  onSubmitted: (_) => _submitSubtask(),
                  decoration: InputDecoration(
                    hintText: context.l10n.task_create_subtasks_hint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _submitSubtask,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          if (subtasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subtasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subtask = subtasks[index];
                final isExpanded = _expandedIndices.contains(index);
                final hasDescription = subtask.description != null && subtask.description!.isNotEmpty;

                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant.withAlpha(125)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.only(left: 4, right: 8),
                        leading: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                            color: cs.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isExpanded) _expandedIndices.remove(index);
                              else _expandedIndices.add(index);
                            });
                          },
                        ),
                        title: Row(
                          children: [
                            Text(subtask.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            if (!isExpanded && hasDescription)
                              Expanded(
                                child: Text(
                                  " • ${subtask.description}",
                                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.5), fontStyle: FontStyle.italic),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: cs.error, size: 20),
                          onPressed: () => ref.read(taskCreateProvider.notifier).removeSubtask(index),
                        ),
                      ),

                      // EDITÁCIA POPISU
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: TextFormField(
                            initialValue: subtask.description,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(fontSize: 13),
                            onChanged: (val) => ref.read(taskCreateProvider.notifier).updateSubtaskDescription(index, val),
                            decoration: InputDecoration(
                              hintText: "Add detailed notes or instructions...", // context.l10n.task_create_subtasks_desc_hint
                              hintStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withAlpha(160)),
                              isDense: true,
                              fillColor: cs.surfaceContainerHigh.withAlpha(100),
                              filled: true,
                              contentPadding: const EdgeInsets.all(12),
                              // Tu je ten obdĺžnik namiesto riadku:
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: cs.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: cs.outlineVariant.withAlpha(100)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: cs.primary.withAlpha(150)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}