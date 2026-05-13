import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../../core/utils/responsive.dart';
import 'progress_list_atoms.dart';

/// A card widget representing a subtask instance in Shared mode.
/// Displays completion status, respondent information, and late submission indicators.
class SharedTaskCard extends StatelessWidget {
  final SubtaskCombinedListModel subtask;

  /// If true, the title is replaced by the respondent's name (used when a task has only one primary subtask).
  final bool isMainTaskOnly;

  const SharedTaskCard({super.key, required this.subtask, this.isMainTaskOnly = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    // Logic for determining if the subtask is overdue or was submitted late
    final isOverdue = !subtask.isCompleted && subtask.deadline.isBefore(DateTime.now());
    final isLate = subtask.isCompleted && subtask.completedAt != null && subtask.completedAt!.isAfter(subtask.deadline);

    // Default styling for pending subtasks
    Color bgColor = cs.surface;
    Color borderColor = cs.outlineVariant;
    IconData icon = Icons.radio_button_unchecked;
    Color iconColor = cs.outline;

    // Styling overrides based on completion and deadline status
    if (subtask.isCompleted) {
      bgColor = isLate ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05);
      borderColor = isLate ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3);
      icon = Icons.check_circle;
      iconColor = isLate ? Colors.red : Colors.green;
    } else if (isOverdue) {
      bgColor = Colors.red.withOpacity(0.05);
      borderColor = Colors.red;
      iconColor = Colors.red;
    }

    Widget content;

    if (isMobile) {
      // --- MOBILE LAYOUT ---
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // Show respondent name as title if it's a "Main Task Only" configuration
                  isMainTaskOnly ? (subtask.respondentName ?? "Unknown") : subtask.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMainTaskOnly ? FontWeight.bold : (isOverdue ? FontWeight.bold : FontWeight.normal),
                    color: subtask.isCompleted ? iconColor : cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (!isMainTaskOnly && subtask.description != null)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 4),
              child: Text(subtask.description!, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ),

          if (subtask.isCompleted) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: cs.outlineVariant.withAlpha(100),
              indent: 36,
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show name at the bottom only if it wasn't already used as the title
                        if (!isMainTaskOnly)
                          Text(
                            subtask.respondentName ?? "Unknown",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subtask.assignedToEmail != null && subtask.assignedToEmail!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: isMainTaskOnly ? 0 : 4),
                            child: Text(subtask.assignedToEmail!, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Display verification badge if the subtask was completed by a logged-in user
                      if (subtask.completedByUserId != null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),
                        ),
                      Text(
                        "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                        style: TextStyle(fontSize: 14, color: iconColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    } else {
      // --- DESKTOP LAYOUT ---
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMainTaskOnly ? (subtask.respondentName ?? "Unknown") : subtask.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMainTaskOnly ? FontWeight.bold : (isOverdue ? FontWeight.bold : FontWeight.normal),
                    color: subtask.isCompleted ? iconColor : cs.onSurface,
                  ),
                ),
                if (!isMainTaskOnly && subtask.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtask.description!, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          if (subtask.isCompleted) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (subtask.completedByUserId != null)
                      const PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),
                    if (subtask.assignedToEmail != null && subtask.assignedToEmail!.isNotEmpty)
                      Text("(${subtask.assignedToEmail})", style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),

                    if (!isMainTaskOnly)
                      Text(
                          subtask.respondentName ?? "Unknown",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                  style: TextStyle(fontSize: 14, color: iconColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: content,
    );
  }
}