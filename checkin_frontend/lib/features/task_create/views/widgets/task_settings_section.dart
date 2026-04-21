import 'package:checkin_frontend/core/shared_widgets/app_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/enums/task_enums.dart';

class TaskSettingsSection extends StatelessWidget {
  final DateTime? selectedDeadline;
  final bool requiresAuth;
  final SubtaskMode currentMode;

  final VoidCallback onDateTap;
  final ValueChanged<DateTime> onDateQuickSelect;
  final ValueChanged<bool> onAuthChanged;
  final ValueChanged<SubtaskMode> onModeChanged;

  const TaskSettingsSection({
    super.key,
    required this.selectedDeadline,
    required this.requiresAuth,
    required this.currentMode,
    required this.onDateTap,
    required this.onDateQuickSelect,
    required this.onAuthChanged,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Použijeme IntrinsicHeight, aby bočné tlačidlá automaticky narástli
    // na výšku stredného stĺpca (Dátum + Chips)
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. WORK MODE (Vysoké tlačidlo)
          Expanded(
            child: AppToggleButton(
              isActive: currentMode == SubtaskMode.shared,
              onTap: () => onModeChanged(
                currentMode == SubtaskMode.shared ? SubtaskMode.individual : SubtaskMode.shared,
              ),
              activeLabel: "Collaborative",
              activeIcon: Icons.group_outlined,
              activeColor: Colors.orange, // Oranžová pre Collaborative
              inactiveLabel: "Independent",
              inactiveIcon: Icons.person_outline,
              inactiveColor: cs.primary, // Modrá pre Independent
              activeTooltip: "One shared list for all",
              inactiveTooltip: "Individual copies for each",
            ),
          ),

          const SizedBox(width: 10),

          // 2. STREDNÝ STĹPEC (Dátum + Chips)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // DÁTUM (Vycentrovaný text)
                Expanded(
                  child: InkWell(
                    onTap: onDateTap,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      textAlign: TextAlign.center, // Vycentrovanie labelu (ak je v strede)
                      decoration: InputDecoration(
                        labelText: "Deadline",
                        labelStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 16),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        filled: true,
                        fillColor: cs.surfaceContainerLow,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.primary.withAlpha(75), width: 1.5),
                        ),
                      ),
                      child: Center( // Vycentrovanie textu dátumu
                        child: Text(
                          selectedDeadline == null
                              ? "Set Date"
                              : DateFormat('dd.MM.yyyy').format(selectedDeadline!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // QUICK CHIPS (Výraznejšie a pri sebe)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickDateChip(label: "1 Day", days: 1, onSelect: onDateQuickSelect, cs: cs),
                    const SizedBox(width: 4),
                    _QuickDateChip(label: "1 Week", days: 7, onSelect: onDateQuickSelect, cs: cs),
                    const SizedBox(width: 4),
                    _QuickDateChip(label: "1 Month", days: 30, onSelect: onDateQuickSelect, cs: cs),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 3. AUTH TOGGLE (Vysoké tlačidlo)
          Expanded(
            child: AppToggleButton(
              isActive: requiresAuth,
              onTap: () => onAuthChanged(!requiresAuth),
              activeLabel: "Verified",
              activeIcon: Icons.lock,
              activeColor: cs.primary, // Tvoja modrá
              inactiveLabel: "Public",
              inactiveIcon: Icons.lock_open,
              inactiveColor: cs.onSurfaceVariant, // Oranžová pre Public
              activeTooltip: "Only Google-signed users",
              inactiveTooltip: "Anyone with a link",
            ),
          ),
        ],
      ),
    );
  }

  Widget _QuickDateChip({
    required String label,
    required int days,
    required ValueChanged<DateTime> onSelect,
    required ColorScheme cs,
  }) {
    return InkWell(
      onTap: () => onSelect(DateTime.now().add(Duration(days: days))),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}