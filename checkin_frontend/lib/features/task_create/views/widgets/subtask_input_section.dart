import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';

class SubtaskInputSection extends ConsumerStatefulWidget {
  final VoidCallback onRemoveSection;

  const SubtaskInputSection({super.key, required this.onRemoveSection});

  @override
  ConsumerState<SubtaskInputSection> createState() => _SubtaskInputSectionState();
}

class _SubtaskInputSectionState extends ConsumerState<SubtaskInputSection> {
  final _inputController = TextEditingController();
  final Set<int> _expandedIndices = {};

  void _submitSubtask() {
    if (_inputController.text.trim().isEmpty) return;
    ref.read(taskCreateProvider.notifier).addSubtask(_inputController.text.trim());
    _inputController.clear();
  }

  @override
  void dispose() {
    _inputController.dispose();
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
              Text("Subtasks", style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
              TextButton(
                onPressed: widget.onRemoveSection,
                child: Text("Remove section", style: TextStyle(color: cs.error, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _submitSubtask(),
                  decoration: InputDecoration(
                    hintText: "Add subtask title...",
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
            const Divider(),
            const SizedBox(height: 8),

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
                        leading: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                            color: cs.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedIndices.remove(index);
                              } else {
                                _expandedIndices.add(index);
                              }
                            });
                          },
                        ),
                        // TITUL + NÁHĽAD POPISU
                        title: Row(
                          children: [
                            Text(subtask.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            if (!isExpanded && hasDescription)
                              Expanded(
                                child: Text(
                                  " • ${subtask.description}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant.withOpacity(0.5),
                                      fontStyle: FontStyle.italic
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () => ref.read(taskCreateProvider.notifier).removeSubtask(index),
                          child: Text("Remove", style: TextStyle(color: cs.error, fontSize: 12)),
                        ),
                      ),

                      // EDITÁCIA POPISU
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(48, 0, 16, 12), // Zarovnané pod text titulu
                          child: TextFormField(
                            initialValue: subtask.description,
                            maxLines: null, // Umožní rásť podľa textu
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(fontSize: 13),
                            onChanged: (val) => ref.read(taskCreateProvider.notifier).updateSubtaskDescription(index, val),
                            decoration: InputDecoration(
                              hintText: "Add description...",
                              hintStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withAlpha(160)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withAlpha(160))),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
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