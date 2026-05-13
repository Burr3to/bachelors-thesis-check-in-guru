import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

/// A reusable widget for displaying dates and deadlines with optional icons.
/// It automatically handles overdue highlighting and supports both relative and absolute formatting.
class DateDisplay extends StatelessWidget {
  final DateTime dateTime;
  final IconData? icon;
  final Color? color;
  final bool showRelative;

  const DateDisplay({
    super.key,
    required this.dateTime,
    this.icon,
    this.color,
    this.showRelative = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Check if the deadline has already passed
    final isOverdue = dateTime.isBefore(DateTime.now());

    // Determine colors: default to red if overdue and no specific color is provided
    final Color displayColor = color ?? (isOverdue ? Colors.red : colorScheme.onSurface);
    final Color iconColor = color ?? (isOverdue ? Colors.red : colorScheme.primary);

    // Format the date based on the chosen style (relative "in 2 days" vs absolute date)
    final String text = showRelative
        ? DateFormatter.formatRelativeDeadline(context, dateTime)
        : DateFormatter.formatCreatedAt(context, dateTime);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional icon with a small gap
        if (icon != null) ...[
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: displayColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}