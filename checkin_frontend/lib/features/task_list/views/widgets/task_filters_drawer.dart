import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/providers/task_providers.dart';

class TaskFiltersDrawer extends ConsumerWidget {
  const TaskFiltersDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(taskQueryProvider);
    final notifier = ref.read(taskQueryProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      width: 350,
      backgroundColor: cs.surface, // EXPLICITNE nastavené pozadie proti priesvitnosti
      surfaceTintColor: cs.surface,
      child: Column(
        children: [
          // HEADER (Pevná farba)
          Container(
            height: 180,
            width: double.infinity,
            color: cs.surfaceContainerLow,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt_rounded, size: 40, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  "Filters & Sorting",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // 1. SORTING
                _buildSectionTitle(cs, "Sort By"),
                DropdownButtonFormField<String>(
                  value: query.sortBy,
                  dropdownColor: cs.surfaceContainerHigh, // Farba dropdown menu
                  decoration: _inputDecoration(cs),
                  items: const [
                    DropdownMenuItem(value: "createdat", child: Text("Creation Date")),
                    DropdownMenuItem(value: "deadline", child: Text("Deadline")),
                    DropdownMenuItem(value: "title", child: Text("Title")),
                  ],
                  onChanged: (val) => notifier.setSort(val!, query.sortDesc),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text("Descending Order", style: TextStyle(fontSize: 14)),
                  value: query.sortDesc,
                  activeColor: cs.primary,
                  onChanged: (val) => notifier.setSort(query.sortBy, val),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),

                // 2. COOPERATION MODE (Toggle logika)
                _buildSectionTitle(cs, "Cooperation Mode"),
                Wrap(
                  spacing: 10,
                  children: [
                    _FilterChip(
                      label: "Shared",
                      selected: query.mode == SubtaskMode.shared,
                      onSelected: (selected) {
                        notifier.setMode(selected ? SubtaskMode.shared : null);
                      },
                    ),
                    _FilterChip(
                      label: "Independent",
                      selected: query.mode == SubtaskMode.individual,
                      onSelected: (selected) {
                        notifier.setMode(selected ? SubtaskMode.individual : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. VISIBILITY (Toggle logika)
                _buildSectionTitle(cs, "Visibility"),
                Wrap(
                  spacing: 10,
                  children: [
                    _FilterChip(
                      label: "Public (Link)",
                      selected: query.requiresAuth == false,
                      onSelected: (selected) {
                        notifier.setVisibility(selected ? false : null);
                      },
                    ),
                    _FilterChip(
                      label: "Private (Verified)",
                      selected: query.requiresAuth == true,
                      onSelected: (selected) {
                        notifier.setVisibility(selected ? true : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. STATUS SPECIAL
                _buildSectionTitle(cs, "Task Status"),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text("Active only", style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text("Tasks before deadline", style: TextStyle(fontSize: 12)),
                        value: query.onlyActive ?? false,
                        activeColor: cs.primary,
                        onChanged: (val) => notifier.setOnlyActive(val ?? false),
                      ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: const Text("Only Overdue", style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text("Tasks after deadline", style: TextStyle(fontSize: 12)),
                        value: query.onlyOverdue ?? false,
                        activeColor: cs.error,
                        onChanged: (val) => notifier.setOverdue(val ?? false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FOOTER
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withAlpha(50))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: () => notifier.reset(),
                icon: const Icon(Icons.refresh),
                label: const Text("Reset All Filters"),
                style: TextButton.styleFrom(
                  foregroundColor: cs.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme cs, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme cs) {
    return InputDecoration(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

// POMOCNÝ WIDGET PRE ŠTÝLOVÝ CHIP
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: cs.primary.withAlpha(40),
      checkmarkColor: cs.primary,
      labelStyle: TextStyle(
        color: selected ? cs.primary : cs.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? cs.primary : cs.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
    );
  }
}