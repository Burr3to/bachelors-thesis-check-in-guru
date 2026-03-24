import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

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
    final isOverdue = dateTime.isBefore(DateTime.now());

    final Color displayColor = color ?? (isOverdue ? Colors.red : colorScheme.onSurface);
    final Color iconColor = color ?? (isOverdue ? Colors.red : colorScheme.primary);

    final String text = showRelative
        ? DateFormatter.formatRelativeDeadline(dateTime)
        : DateFormatter.formatCreatedAt(dateTime);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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