import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'l10n_extensions.dart';

class DateFormatter {
  static String formatRelativeDeadline(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = localDateTime.difference(now);

    if (difference.isNegative) {
      if (difference.inDays.abs() == 0) return context.l10n.date_expired_today;
      return context.l10n.date_overdue_days_ago(difference.inDays.abs());
    }

    final today = DateTime(now.year, now.month, now.day);
    final dateToCompare = DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
    final dayDiff = dateToCompare.difference(today).inDays;
    final timeStr = DateFormat('HH:mm').format(localDateTime);

    if (dayDiff == 0) return context.l10n.date_today_at(timeStr);
    if (dayDiff == 1) return context.l10n.date_tomorrow_at(timeStr);
    if (dayDiff < 30) return context.l10n.date_in_days(dayDiff);

    return DateFormat('dd.MM.yyyy').format(localDateTime);
  }

  static String formatCreatedAt(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());

    if (diff.inMinutes < 1) return context.l10n.date_just_now;
    if (diff.inMinutes < 60) return context.l10n.date_mins_ago(diff.inMinutes);
    if (diff.inHours < 24) return context.l10n.date_hours_ago(diff.inHours);
    if (diff.inDays < 7) return context.l10n.date_days_ago(diff.inDays);

    return DateFormat('dd.MM.yyyy').format(dateTime.toLocal());
  }
}
