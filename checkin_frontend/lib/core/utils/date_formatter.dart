import 'package:intl/intl.dart';

class DateFormatter {
  static String formatRelativeDeadline(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = localDateTime.difference(now);

    // 1. Minulosť
    if (difference.isNegative) {
      if (difference.inDays.abs() == 0) return "Expired today";
      return "Expired ${difference.inDays.abs()} days ago";
    }

    final today = DateTime(now.year, now.month, now.day);
    final dateToCompare = DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
    final dayDiff = dateToCompare.difference(today).inDays;

    // 2. Today
    if (dayDiff == 0) {
      return "Today at ${DateFormat('HH:mm').format(localDateTime)}";
    }

    // 3. Tomorrow
    if (dayDiff == 1) {
      return "Tomorrow at ${DateFormat('HH:mm').format(localDateTime)}";
    }

    // 4. This week
    if (dayDiff < 7) {
      return "In $dayDiff days (${DateFormat('EEEE').format(localDateTime)})";
    }

    // 5. Before 30 days
    if (dayDiff < 30) {
      return "In $dayDiff days";
    }

    // 6. Future
    return DateFormat('dd.MM.yyyy').format(localDateTime);
  }

  static String formatCreatedAt(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return DateFormat('dd.MM.yyyy').format(dateTime.toLocal());
  }
}