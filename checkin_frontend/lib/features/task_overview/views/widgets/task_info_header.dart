import 'package:checkin_frontend/core/shared_widgets/date_display.dart';
import 'package:flutter/material.dart';

class TaskInfoHeader extends StatelessWidget {
  final DateTime createdDate;
  final DateTime deadlineDate;
  final DateTime lastModified;
  final bool requiresAuth;
  final VoidCallback? onDeadlineTap;

  const TaskInfoHeader({
    super.key,
    required this.createdDate,
    required this.deadlineDate,
    required this.requiresAuth,
    required this.lastModified,
    this.onDeadlineTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withAlpha(125))
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: SelectionArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: onDeadlineTap,
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(8),
              hoverColor: colorScheme.primary.withAlpha(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Deadline",
                            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit, size: 12, color: colorScheme.primary.withAlpha(150)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    DateDisplay(dateTime: deadlineDate, icon: Icons.alarm),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Created On", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 6),
                DateDisplay(
                  dateTime: createdDate,
                  icon: Icons.calendar_today,
                  color: Colors.grey,
                  showRelative: false,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Last Modified", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DateDisplay(
                  dateTime: lastModified,
                  icon: Icons.edit,
                  color: Colors.grey,
                  showRelative: false,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Identity Verification",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      requiresAuth ? Icons.verified_user : Icons.no_encryption_outlined,
                      size: 16,
                      color: requiresAuth ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      requiresAuth
                          ? "Required"
                          : "Not Required", // "Required" znie lepšie ako "Enabled"
                      style: TextStyle(
                        color: requiresAuth ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
