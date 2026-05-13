import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Potrebné pre DateFormat

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/quill_viewer.dart';
import '../../../../core/utils/responsive.dart';

class TaskHeader extends StatelessWidget {
  final String title;
  final String? notes;
  final DateTime deadline;

  const TaskHeader({super.key, required this.title, this.notes, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // --- LOGIKA FARIEB A IKON ---
    final now = DateTime.now();
    final localDeadline = deadline.toLocal();

    final isOverdue = now.isAfter(localDeadline);
    final isToday = now.year == localDeadline.year &&
        now.month == localDeadline.month &&
        now.day == localDeadline.day;

    Color badgeColor;
    IconData badgeIcon;

    if (isOverdue) {
      badgeColor = cs.error; // Červená pre zmeškané
      badgeIcon = Icons.error_outline;
    } else if (isToday) {
      badgeColor = Colors.orange; // Oranžová pre dnešný termín
      badgeIcon = Icons.schedule;
    } else {
      badgeColor = cs.primary; // Primárna pre normálnu budúcnosť
      badgeIcon = Icons.calendar_today;
    }

    // --- TEXTY ---
    // Hlavný text: Normálny absolútny dátum (napr. 15.05.2026 14:00)
    final absoluteDateStr = DateFormat('dd.MM.yyyy HH:mm').format(localDeadline);
    // Podnadpis: Relatívny text z tvojho formattera (napr. "Zajtra o 14:00" alebo "Dnes o 14:00")
    final relativeDateStr = DateFormatter.formatRelativeDeadline(context, deadline);

    return Column(
      children:[
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Mierne zväčšený padding pre 2 riadky
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12), // Zmenšený radius, pri 2 riadkoch to vyzerá lepšie ako úplná "tabletka"
              border: Border.all(color: badgeColor.withAlpha(125)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                Icon(badgeIcon, size: 24, color: badgeColor), // Zväčšená ikona, aby ladila k 2 riadkom
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
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
                        color: badgeColor.withAlpha(200), // Trochu priehľadnejšia/menej výrazná farba pre relatívny text
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
        if (notes != null) ...[QuillViewer(jsonText: notes), SizedBox(height: context.isMobile ? 16 : 24)],
      ],
    );
  }
}