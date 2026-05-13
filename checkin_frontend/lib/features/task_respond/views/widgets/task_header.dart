import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/quill_viewer.dart';
import '../../../../core/utils/responsive.dart';

/// A header widget for the task view.
/// Displays a color-coded status badge for the deadline, the task title,
/// and formatted rich-text notes.
class TaskHeader extends StatelessWidget {
  final String title;
  final String? notes;
  final DateTime deadline;

  const TaskHeader({super.key, required this.title, this.notes, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Time calculations for visual status
    final now = DateTime.now();
    final localDeadline = deadline.toLocal();

    final isOverdue = now.isAfter(localDeadline);
    final isToday = now.year == localDeadline.year &&
        now.month == localDeadline.month &&
        now.day == localDeadline.day;

    // Define colors and icons based on proximity to the deadline
    Color badgeColor;
    IconData badgeIcon;

    if (isOverdue) {
      badgeColor = cs.error; // Red for overdue tasks
      badgeIcon = Icons.error_outline;
    } else if (isToday) {
      badgeColor = Colors.orange; // Orange for tasks due today
      badgeIcon = Icons.schedule;
    } else {
      badgeColor = cs.primary; // Primary color for future tasks
      badgeIcon = Icons.calendar_today;
    }

    // Formatting date strings
    // Primary text: Absolute date (e.g., 15.05.2026 14:00)
    final absoluteDateStr = DateFormat('dd.MM.yyyy HH:mm').format(localDeadline);
    // Secondary text: Relative date (e.g., "Tomorrow at 14:00")
    final relativeDateStr = DateFormatter.formatRelativeDeadline(context, deadline);

    return Column(
      children: [
        // Centered status badge containing both absolute and relative time
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withAlpha(125)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(badgeIcon, size: 24, color: badgeColor),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      absoluteDateStr,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      relativeDateStr,
                      style: TextStyle(
                        color: badgeColor.withAlpha(200),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.isMobile ? 12 : 16),

        // Task Title with responsive font size
        Text(
          title,
          style: (context.isMobile
              ? Theme.of(context).textTheme.titleLarge
              : Theme.of(context).textTheme.headlineMedium)?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.isMobile ? 8 : 12),

        // Rich text notes rendered via QuillViewer
        if (notes != null) ...[
          QuillViewer(jsonText: notes),
          SizedBox(height: context.isMobile ? 16 : 24)
        ],
      ],
    );
  }
}