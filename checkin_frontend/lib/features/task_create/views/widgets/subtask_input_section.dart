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
  final Set<int> _expandedIndices = {}; // Track which subtasks show description

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
          // HEADER
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

          // INPUT FIELD + PLUS BUTTON
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

            // LIST OF ADDED SUBTASKS
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subtasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subtask = subtasks[index];
                final isExpanded = _expandedIndices.contains(index);

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
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
                                  if (isExpanded) _expandedIndices.remove(index);
                                  else _expandedIndices.add(index);
                                });
                              },
                            ),
                            title: Text(subtask.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            trailing: TextButton(
                              onPressed: () => ref.read(taskCreateProvider.notifier).removeSubtask(index),
                              child: Text("Remove", style: TextStyle(color: cs.error, fontSize: 12)),
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: TextField(
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: "Add description (optional)...",
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: UnderlineInputBorder(),
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) => ref.read(taskCreateProvider.notifier).updateSubtaskDescription(index, val),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}