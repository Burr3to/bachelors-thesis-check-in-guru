import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../../core/shared_widgets/segmented_progress_bar.dart';
import '../../../../../core/utils/responsive.dart';
import 'progress_list_atoms.dart'; // Import atómov

class RespondentCard extends StatelessWidget {
  final String groupId;
  final List<SubtaskCombinedListModel> items;
  final int totalTemplates;
  final bool isExpanded;
  final ValueChanged<bool> onToggle;
  final bool isMainTaskOnly;

  const RespondentCard({
    super.key,
    required this.groupId,
    required this.items,
    required this.totalTemplates,
    required this.isExpanded,
    required this.onToggle,
    required this.isMainTaskOnly,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;
    final firstItem = items.first;

    final respondentName = firstItem.respondentName ?? "";
    final respondentEmail = items.firstWhereOrNull((s) => true)?.assignedToEmail;
    final isVerified = items.any((s) => s.completedByUserId != null);
    final int completedCount = items.where((s) => s.isCompleted).length;

    final bool hasOverdue = items.any((s) => !s.isCompleted && s.deadline.isBefore(DateTime.now()));
    final isLate = isMainTaskOnly && firstItem.isCompleted && firstItem.completedAt != null && firstItem.completedAt!.isAfter(firstItem.deadline);

    Color progressColor = cs.primary;
    String? statusLabel;
    IconData? statusIcon;
    Color? statusColor;

    if (completedCount == totalTemplates) {
      progressColor = isLate ? Colors.red : Colors.green;
      if (isLate) {
        statusLabel = "Late";
        statusIcon = Icons.access_time_filled;
        statusColor = Colors.red;
      } else {
        statusLabel = "Complete";
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
      }
    } else if (hasOverdue) {
      progressColor = cs.error;
      int overdueCount = items.where((s) => !s.isCompleted && s.deadline.isBefore(DateTime.now())).length;
      statusLabel = "$overdueCount Overdue";
      statusIcon = Icons.error_outline;
      statusColor = cs.error;
    } else if (completedCount > 0) {
      progressColor = cs.primary;
      statusLabel = "In Progress";
      statusIcon = Icons.autorenew;
      statusColor = Colors.orange;
    }

    Widget headerContent;

    if (isMobile) {
      headerContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              AvatarCircle(name: respondentName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Row(
                      children:[
                        Flexible(
                          child: Text(
                            respondentName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          const PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),
                        ],
                      ],
                    ),
                    if (respondentEmail != null && respondentEmail.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(respondentEmail, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                      ),
                  ],
                ),
              ),
              if (!isMainTaskOnly)
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: cs.onSurfaceVariant),
            ],
          ),
          if (statusLabel != null && statusColor != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: PillBadge(icon: statusIcon!, text: statusLabel, color: statusColor),
            ),
          const SizedBox(height: 8),
          if (!isMainTaskOnly)
            Row(
              children:[
                Expanded(child: SegmentedProgressBar(green: completedCount, grey: totalTemplates - completedCount, height: 8)),
                const SizedBox(width: 12),
                Text("$completedCount/$totalTemplates", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: progressColor)),
              ],
            )
          else if (firstItem.isCompleted && firstItem.completedAt != null)
            Text(
              DateFormat('dd.MM HH:mm').format(firstItem.completedAt!.toLocal()),
              style: TextStyle(fontSize: 13, color: progressColor, fontWeight: FontWeight.bold),
            ),
        ],
      );
    } else {
      headerContent = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          AvatarCircle(name: respondentName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children:[
                    Text(respondentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (respondentEmail != null && respondentEmail.isNotEmpty)
                      Text("($respondentEmail)", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                    if (isVerified)
                      const PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),
                    if (statusLabel != null && statusColor != null)
                      PillBadge(icon: statusIcon!, text: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 8),
                if (!isMainTaskOnly)
                  SegmentedProgressBar(green: completedCount, grey: totalTemplates - completedCount, height: 6),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (!isMainTaskOnly) ...[
            Text("$completedCount/$totalTemplates", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: progressColor)),
            const SizedBox(width: 8),
            Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: cs.onSurfaceVariant),
          ] else if (firstItem.isCompleted && firstItem.completedAt != null) ...[
            Text(
              DateFormat('dd.MM HH:mm').format(firstItem.completedAt!.toLocal()),
              style: TextStyle(fontSize: 13, color: progressColor, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Column(
        children:[
          InkWell(
            onTap: isMainTaskOnly ? null : () => onToggle(!isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: headerContent,
            ),
          ),
          if (!isMainTaskOnly)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children:[
                  Divider(height: 1, color: cs.outlineVariant.withAlpha(100)),
                  ...items.map((s) => TaskItemRow(subtask: s)),
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
        ],
      ),
    );
  }
}

// Atomický widget riadku úlohy, patrí výhradne k Individual Modu
class TaskItemRow extends StatelessWidget {
  final SubtaskCombinedListModel subtask;
  const TaskItemRow({super.key, required this.subtask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    final isOverdue = !subtask.isCompleted && subtask.deadline.isBefore(DateTime.now());
    final isLate = subtask.isCompleted && subtask.completedAt != null && subtask.completedAt!.isAfter(subtask.deadline);

    Color rowColor = Colors.transparent;
    Color contentColor = cs.onSurface;
    IconData icon = Icons.circle_outlined;

    if (subtask.isCompleted) {
      rowColor = isLate ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05);
      contentColor = isLate ? Colors.red : Colors.green;
      icon = Icons.check_circle;
    } else if (isOverdue) {
      rowColor = Colors.red.withOpacity(0.05);
      contentColor = Colors.red;
      icon = Icons.error_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 10),
      color: rowColor,
      child: Row(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children:[
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 2.0 : 0.0),
            child: Icon(icon, size: 18, color: contentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: contentColor,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (subtask.isCompleted && subtask.completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children:[
                        Icon(Icons.access_time, size: 12, color: contentColor.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                          style: TextStyle(fontSize: 12, color: contentColor.withAlpha(255)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}