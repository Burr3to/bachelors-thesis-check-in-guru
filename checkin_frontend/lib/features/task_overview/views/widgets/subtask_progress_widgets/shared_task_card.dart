import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../../core/utils/responsive.dart';
import 'progress_list_atoms.dart'; // Import atómov

class SharedTaskCard extends StatelessWidget {
  final SubtaskCombinedListModel subtask;
  final bool isMainTaskOnly;

  const SharedTaskCard({super.key, required this.subtask, this.isMainTaskOnly = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;
    final isOverdue = !subtask.isCompleted && subtask.deadline.isBefore(DateTime.now());
    final isLate = subtask.isCompleted && subtask.completedAt != null && subtask.completedAt!.isAfter(subtask.deadline);

    Color bgColor = cs.surface;
    Color borderColor = cs.outlineVariant;
    IconData icon = Icons.radio_button_unchecked;
    Color iconColor = cs.outline;

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
      // MOBILNÁ VERZIA
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  // Ak je to iba hlavná úloha, vypíše sa MENO sem
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
                children:[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        // OPRAVA: Meno dole sa vypíše IBA ak to nie je hlavná úloha (aby nebolo duplicitné s nadpisom)
                        if (!isMainTaskOnly)
                          Text(
                            subtask.respondentName ?? "Unknown",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subtask.assignedToEmail != null && subtask.assignedToEmail!.isNotEmpty)
                          Padding(
                            // Upravený padding aby email neskákal dole ak tam nie je meno
                            padding: EdgeInsets.only(top: isMainTaskOnly ? 0 : 4),
                            child: Text(subtask.assignedToEmail!, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:[
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
      // DESKTOP VERZIA
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(
                  // Tu sa na desktope vypíše meno ak je to hlavná úloha
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
              children:[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children:[
                    // OPRAVA PRE DESKTOP: Odznak a e-mail sa teraz ukážu vždy, ale duplicitné meno sa schová
                    if (subtask.completedByUserId != null)
                      const PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),
                    if (subtask.assignedToEmail != null && subtask.assignedToEmail!.isNotEmpty)
                      Text("(${subtask.assignedToEmail})", style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),

                    if (!isMainTaskOnly)
                      Text(subtask.respondentName ?? "Unknown", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)),
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