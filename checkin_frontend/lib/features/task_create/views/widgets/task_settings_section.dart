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
                activeTooltip: "Collaborative: One list for everyone. Anyone can complete tasks for the whole group. Everyone sees shared progress and names.",
                inactiveTooltip: "Independent: Each participant gets their own private copy. Progress is separate for every person who opens the link.",

                activeLabel: "Collaborative",
                activeIcon: Icons.group_outlined,
                activeColor: Colors.blue,
                inactiveLabel: "Independent",
                inactiveIcon: Icons.person_outline,
                inactiveColor: Colors.orange,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: InkWell(
                onTap: onDateTap,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Deadline",
                    labelStyle: const TextStyle(color: Colors.blueAccent),
                    isDense: true,

                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                    ),

                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent, size: 20),
                  ),
                  child: Text(
                    selectedDeadline == null
                        ? "Set Deadline"
                        : DateFormat('dd.MM.yyyy').format(selectedDeadline!),
                    style: const TextStyle(fontSize: 15), // Môžeš tiež upraviť veľkosť písma
                  ),
                ),
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
                activeTooltip: "Only users signed in through Google can confirm sasks",

                inactiveLabel: "Public",
                inactiveIcon: Icons.lock_open,
                inactiveColor: Colors.black54, // Pre Public dáme šedú
                inactiveTooltip: "Everyone has access with a link, beware of duplicates from one person",
              ),
            ),
          ],
        ),



      ],
    );
  }
}
