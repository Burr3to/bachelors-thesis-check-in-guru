import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';

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
                  context.l10n.tasks_filter_title,
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
                _buildSectionTitle(cs, context.l10n.tasks_filter_sort_by),
                DropdownButtonFormField<String>(
                  value: query.sortBy,
                  dropdownColor: cs.surfaceContainerHigh, // Farba dropdown menu
                  decoration: _inputDecoration(cs),
                  items: [
                    DropdownMenuItem(value: "createdat", child: Text(context.l10n.tasks_filter_created_at)),
                    DropdownMenuItem(value: "deadline", child: Text(context.l10n.tasks_filter_deadline)),
                    DropdownMenuItem(value: "title", child: Text(context.l10n.tasks_filter_title_field)),
                  ],
                  onChanged: (val) => notifier.setSort(val!, query.sortDesc),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(context.l10n.tasks_filter_descending, style: const TextStyle(fontSize: 14)),
                  value: query.sortDesc,
                  activeColor: cs.primary,
                  onChanged: (val) => notifier.setSort(query.sortBy, val),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),

                // 2. COOPERATION MODE (Toggle logika)
                _buildSectionTitle(cs, context.l10n.tasks_filter_mode),
                Wrap(
                  spacing: 10,
                  children: [
                    _FilterChip(
                      label: context.l10n.task_create_mode_collab,
                      selected: query.mode == SubtaskMode.shared,
                      onSelected: (selected) {
                        notifier.setMode(selected ? SubtaskMode.shared : null);
                      },
                    ),
                    _FilterChip(
                      label: context.l10n.task_create_mode_indep,
                      selected: query.mode == SubtaskMode.individual,
                      onSelected: (selected) {
                        notifier.setMode(selected ? SubtaskMode.individual : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. VISIBILITY (Toggle logika)
                _buildSectionTitle(cs, context.l10n.tasks_filter_visibility),
                Wrap(
                  spacing: 10,
                  children: [
                    _FilterChip(
                      label: context.l10n.task_create_auth_public,
                      selected: query.requiresAuth == false,
                      onSelected: (selected) {
                        notifier.setVisibility(selected ? false : null);
                      },
                    ),
                    _FilterChip(
                      label: context.l10n.task_create_auth_verified,
                      selected: query.requiresAuth == true,
                      onSelected: (selected) {
                        notifier.setVisibility(selected ? true : null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. STATUS SPECIAL
                _buildSectionTitle(cs, context.l10n.tasks_filter_status),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(context.l10n.tasks_filter_active_only, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(context.l10n.tasks_filter_active_subtitle, style: const TextStyle(fontSize: 12)),
                        value: query.onlyActive ?? false,
                        activeColor: cs.primary,
                        onChanged: (val) => notifier.setOnlyActive(val ?? false),
                      ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        title: Text(context.l10n.tasks_filter_overdue_only, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(context.l10n.tasks_filter_overdue_subtitle, style: const TextStyle(fontSize: 12)),
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
                label: Text(context.l10n.tasks_filter_reset),
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