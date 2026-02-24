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
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppToggleButton(
                isActive: currentMode == SubtaskMode.shared,
                onTap: () {
                  final newMode = currentMode == SubtaskMode.shared
                      ? SubtaskMode.individual
                      : SubtaskMode.shared;
                  onModeChanged(newMode);
                },
                activeLabel: "Group list for everyone",
                activeIcon: Icons.group_outlined,
                activeColor: Colors.blue,
                inactiveLabel: "Personal for each participant",
                inactiveIcon: Icons.person_outline,
                inactiveColor: Colors.orange,
              ),
            ),

            const SizedBox(width: 12),

            // 2. AUTH TOGGLE (Teraz používa dynamický widget)
            Expanded(
              child: AppToggleButton(
                isActive: requiresAuth,
                onTap: () => onAuthChanged(!requiresAuth),
                activeLabel: "Verified Only",
                activeIcon: Icons.lock,
                activeColor: Colors.blue,
                inactiveLabel: "Public",
                inactiveIcon: Icons.lock_open,
                inactiveColor: Colors.black54, // Pre Public dáme šedú
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        InkWell(
          onTap: onDateTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Deadline",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              isDense: true,
              suffixIcon: Icon(Icons.calendar_today, size: 20),
            ),
            child: Text(
              selectedDeadline == null
                  ? "Set Deadline"
                  : DateFormat('dd.MM.yyyy').format(selectedDeadline!),
            ),
          ),
        ),
      ],
    );
  }
}
