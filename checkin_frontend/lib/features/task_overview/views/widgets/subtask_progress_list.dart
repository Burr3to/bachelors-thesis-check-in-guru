import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/shared_widgets/segmented_progress_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/models/subtask_instance/subtask_combined_list_model.dart';

class SubtaskProgressList extends ConsumerStatefulWidget {
  final List<SubtaskCombinedListModel> subtasks;
  final List<SubtaskCombinedListModel> templates;
  final SubtaskMode subtaskMode;

  const SubtaskProgressList({
    super.key,
    required this.subtasks,
    required this.templates,
    required this.subtaskMode,
  });

  @override
  ConsumerState<SubtaskProgressList> createState() => _SubtaskProgressListState();
}

class _SubtaskProgressListState extends ConsumerState<SubtaskProgressList> {
  // Mapa pre sledovanie stavu otvorenia harmoník (pre Individual mode)
  final Map<String, bool> _expandedStates = {};

  void _setAllExpanded(bool expanded, List<String> groupIds) {
    setState(() {
      for (var id in groupIds) {
        _expandedStates[id] = expanded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Celý widget obalíme do Containeru s borderom
    return Container(
      padding: const EdgeInsets.all(16), // Konzistentný padding vnútri boxu
      decoration: BoxDecoration(
        color: cs.surface, // Čisté pozadie celého bloku
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary, width: 1), // Modrý border podľa zadania
      ),
      child: _buildContent(context, cs),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs) {
    if (widget.subtasks.isEmpty) return _buildEmptyState(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtaskMode == SubtaskMode.individual)
          _buildIndividualMode(context, cs)
        else
          _buildSharedMode(context, cs),
      ],
    );
  }

  // --- INDIVIDUAL MODE ---

  Widget _buildIndividualMode(BuildContext context, ColorScheme cs) {
    final grouped = groupBy(widget.subtasks, (s) => s.responseGroupId);
    final groupIds = grouped.keys.map((e) => e.toString()).toList();
    final int respondentCount = grouped.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header s ovládacími prvkami
        Row(
          children: [
            Text(
              "Individual Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const Spacer(),
            Text(
              "$respondentCount Respondents",
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.unfold_more, size: 20),
              onPressed: () => _setAllExpanded(true, groupIds),
              tooltip: "Expand All",
            ),
            IconButton(
              icon: const Icon(Icons.unfold_less, size: 20),
              onPressed: () => _setAllExpanded(false, groupIds),
              tooltip: "Collapse All",
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Zoznam respondentov
        ...grouped.entries.map((entry) {
          final groupId = entry.key;
          final items = entry.value;
          return _RespondentAccordion(
            groupId: groupId,
            items: items,
            totalTemplates: widget.templates.length,
            isExpanded: _expandedStates[groupId] ?? false,
            onToggle: (val) => setState(() => _expandedStates[groupId] = val),
          );
        }),
      ],
    );
  }

  // --- SHARED MODE ---

  Widget _buildSharedMode(BuildContext context, ColorScheme cs) {
    final int completed = widget.subtasks.where((s) => s.isCompleted).length;
    final int total = widget.subtasks.length;
    final int remaining = total - completed;
    final int percent = total > 0 ? ((completed / total) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RIADOK NAD BAROM (Text vpravo hore)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Shared Progress",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            // Tento text bude vpravo hore nad barom
            Text(
              "$completed/$total ($percent%)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.primary),
            ),
          ],
        ),
        const SizedBox(height: 8), // Medzera medzi textom a barom
        SegmentedProgressBar(
          green: completed,
          grey: remaining,
          height: 12, // Výška baru
        ),
        const SizedBox(height: 24),
        ...widget.subtasks.map((s) => _SharedTaskCard(subtask: s)),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(
          context.l10n.overview_progress_empty,
          style: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

// --- POMOCNÉ KOMPONENTY PRE INDIVIDUAL MODE ---

class _RespondentAccordion extends StatelessWidget {
  final String groupId;
  final List<SubtaskCombinedListModel> items;
  final int totalTemplates;
  final bool isExpanded;
  final ValueChanged<bool> onToggle;

  const _RespondentAccordion({
    required this.groupId,
    required this.items,
    required this.totalTemplates,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final respondentName =
        items.firstWhereOrNull((s) => s.respondentName != null)?.respondentName ?? "Not started";
    final isVerified = items.any((s) => s.completedByUserId != null);

    // Logika pre statusy
    final int completedCount = items.where((s) => s.isCompleted).length;
    final bool hasOverdue = items.any((s) => !s.isCompleted && s.deadline.isBefore(DateTime.now()));
    final double percent = totalTemplates > 0 ? completedCount / totalTemplates : 0;

    Color progressColor = cs.primary;
    String statusLabel = "In Progress";
    Color statusColor = Colors.orange;

    if (completedCount == totalTemplates) {
      progressColor = Colors.green;
      statusLabel = "Complete";
      statusColor = Colors.green;
    } else if (hasOverdue) {
      progressColor = cs.error;
      int overdueCount = items
          .where((s) => !s.isCompleted && s.deadline.isBefore(DateTime.now()))
          .length;
      statusLabel = "$overdueCount Overdue";
      statusColor = cs.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(groupId),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onToggle,
          leading: _AvatarCircle(name: respondentName),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(respondentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 14, color: cs.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(label: statusLabel, color: statusColor),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // PRAVÁ ČASŤ S TEXTOM HORE A BAROM DOLE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$completedCount/$totalTemplates",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 80,
                    child: SegmentedProgressBar(
                      green: completedCount,
                      orange: 0, // Tu môžeš pridať logic pre inProgress ak chceš
                      grey: totalTemplates - completedCount,
                      height: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            ...items.map((s) => _TaskItemRow(subtask: s)),
          ],
        ),
      ),
    );
  }
}

// --- POMOCNÉ KOMPONENTY PRE SHARED MODE ---

class _SharedTaskCard extends StatelessWidget {
  final SubtaskCombinedListModel subtask;

  const _SharedTaskCard({required this.subtask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOverdue = !subtask.isCompleted && subtask.deadline.isBefore(DateTime.now());
    final isLate =
        subtask.isCompleted &&
        subtask.completedAt != null &&
        subtask.completedAt!.isAfter(subtask.deadline);

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
      //icon = Icons.warning_rounded;
      iconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                    color: subtask.isCompleted ? iconColor : cs.onSurface,
                  ),
                ),
                if (subtask.description != null)
                  Text(
                    subtask.description!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (subtask.isCompleted) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (subtask.completedByUserId != null)
                      Icon(Icons.verified, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      subtask.respondentName ?? "Unknown",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor),
                    ),
                  ],
                ),
                Text(
                  "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                  style: TextStyle(fontSize: 13, color: iconColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// --- ATOMICKÉ PRVKY (Znovu použiteľné) ---

class _TaskItemRow extends StatelessWidget {
  final SubtaskCombinedListModel subtask;
  const _TaskItemRow({required this.subtask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOverdue = !subtask.isCompleted && subtask.deadline.isBefore(DateTime.now());
    final isLate =
        subtask.isCompleted &&
        subtask.completedAt != null &&
        subtask.completedAt!.isAfter(subtask.deadline);

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: rowColor,
      child: Row(
        children: [
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: contentColor,
                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (subtask.isCompleted && subtask.completedAt != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 10, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                        style: TextStyle(fontSize: 10, color: contentColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  const _AvatarCircle({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;

  const _CustomProgressBar({required this.value, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height / 2)),
        ),
      ),
    );
  }
}
