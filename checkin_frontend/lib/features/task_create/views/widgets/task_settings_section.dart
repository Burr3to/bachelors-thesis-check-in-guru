import 'package:checkin_frontend/features/task_create/views/widgets/app_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/enums/task_enums.dart';

class TaskSettingsSection extends StatelessWidget {
  final DateTime? selectedDeadline;
  final bool requiresAuth;
  final SubtaskMode currentMode;

  final VoidCallback onDateTap;
  final ValueChanged<bool> onAuthChanged;
  final ValueChanged<SubtaskMode> onModeChanged;

  const TaskSettingsSection({
    super.key,
    required this.selectedDeadline,
    required this.requiresAuth,
    required this.currentMode,
    required this.onDateTap,
    required this.onAuthChanged,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. COLLABORATIVE / INDIVIDUAL TOGGLE
            Expanded(
              child: AppToggleButton(
                isActive: currentMode == SubtaskMode.shared,
                onTap: () {
                  final newMode = currentMode == SubtaskMode.shared
                      ? SubtaskMode.individual
                      : SubtaskMode.shared;
                  onModeChanged(newMode);
                },
                activeTooltip: "Collaborative: One list for everyone. Anyone can complete tasks for the whole group.",
                inactiveTooltip: "Independent: Each participant gets their own private copy.",

                activeLabel: "Collaborative",
                activeIcon: Icons.group_outlined,
                activeColor: cs.primary, // Použije tvoju modrú z témy
                inactiveLabel: "Independent",
                inactiveIcon: Icons.person_outline,
                inactiveColor: Colors.orange, // Ponecháme oranžovú pre vizuálne odlíšenie módov
              ),
            ),

            const SizedBox(width: 12),

            // 2. DEADLINE PICKER
            Expanded(
              child: InkWell(
                onTap: onDateTap,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Deadline",
                    labelStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

                    // Pozadie pre deadline (voliteľné, aby ladilo s Buttonmi)
                    filled: true,
                    fillColor: cs.surfaceContainerLow,

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary.withOpacity(0.5), width: 2),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),

                    suffixIcon: Icon(Icons.calendar_today, color: cs.primary, size: 20),
                  ),
                  child: Text(
                    selectedDeadline == null
                        ? "Set Deadline"
                        : DateFormat('dd.MM.yyyy').format(selectedDeadline!),
                    style: TextStyle(
                      fontSize: 15,
                      color: cs.onSurface, // Zabezpečí čitateľnosť v dark/light
                      fontWeight: selectedDeadline != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 3. AUTH TOGGLE
            Expanded(
              child: AppToggleButton(
                isActive: requiresAuth,
                onTap: () => onAuthChanged(!requiresAuth),
                activeLabel: "Verified Only",
                activeIcon: Icons.lock,
                activeColor: cs.primary,
                activeTooltip: "Only users signed in through Google can confirm tasks",

                inactiveLabel: "Public",
                inactiveIcon: Icons.lock_open,
                // Namiesto black54 použijeme onSurfaceVariant (v light sivá, v dark biela70)
                inactiveColor: cs.onSurfaceVariant,
                inactiveTooltip: "Everyone has access with a link, beware of duplicates from one person",
              ),
            ),
          ],
        ),
      ],
    );
  }
}