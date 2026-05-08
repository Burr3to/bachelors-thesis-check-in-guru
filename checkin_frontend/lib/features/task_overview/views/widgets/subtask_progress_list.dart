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
  final bool isMainTaskOnly;

  const SubtaskProgressList({
    super.key,
    required this.subtasks,
    required this.templates,
    required this.subtaskMode,
    this.isMainTaskOnly = false,
  });

  @override
  ConsumerState<SubtaskProgressList> createState() => _SubtaskProgressListState();
}

class _SubtaskProgressListState extends ConsumerState<SubtaskProgressList> {
  final Map<String, bool> _expandedStates = {};

  // Táto metóda teraz funguje správne, vďaka nahradeniu ExpansionTile
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary, width: 0.8),
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
        Row(
          children: [
            Text("Individual Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const Spacer(),
            Text("$respondentCount Respondents", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),

            // Expand / Collapse
            if (!widget.isMainTaskOnly) ...[
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.unfold_more, size: 20), onPressed: () => _setAllExpanded(true, groupIds), tooltip: "Expand All"),
              IconButton(icon: const Icon(Icons.unfold_less, size: 20), onPressed: () => _setAllExpanded(false, groupIds), tooltip: "Collapse All"),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          return _RespondentCard(
            groupId: entry.key,
            items: entry.value,
            totalTemplates: widget.templates.length,
            isExpanded: _expandedStates[entry.key] ?? false,
            onToggle: (val) => setState(() => _expandedStates[entry.key] = val),
            isMainTaskOnly: widget.isMainTaskOnly,
          );
        }),
      ],
    );
  }

  // --- SHARED MODE ---
  Widget _buildSharedMode(BuildContext context, ColorScheme cs) {
    final displayTasks = widget.isMainTaskOnly
        ? widget.subtasks.where((s) => s.isCompleted).toList()
        : widget.subtasks;

    final int completed = displayTasks.where((s) => s.isCompleted).length;
    final int total = displayTasks.length;
    final int remaining = total - completed;
    final int percent = total > 0 ? ((completed / total) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.isMainTaskOnly ? "Signatures / Completions" : "Shared Progress",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            if (!widget.isMainTaskOnly)
              Text("$completed/$total ($percent%)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: cs.primary)),
          ],
        ),

        if (!widget.isMainTaskOnly) ...[
          const SizedBox(height: 8),
          SegmentedProgressBar(green: completed, grey: remaining, height: 12),
        ],

        const SizedBox(height: 24),
        if (displayTasks.isEmpty && widget.isMainTaskOnly)
          _buildEmptyState(cs)
        else
          ...displayTasks.map((s) => _SharedTaskCard(subtask: s, isMainTaskOnly: widget.isMainTaskOnly)),
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

// --- KARTA PRE RESPONDENTA (Individual Mode) ---
class _RespondentCard extends StatelessWidget {
  final String groupId;
  final List<SubtaskCombinedListModel> items;
  final int totalTemplates;
  final bool isExpanded;
  final ValueChanged<bool> onToggle;
  final bool isMainTaskOnly;

  const _RespondentCard({
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
    final firstItem = items.first;

    final respondentName = firstItem.respondentName ?? "Not started";
    // Uistite sa, že máte 'respondentEmail' v modeli, inak tu dajte null.
    // Ak to tvoj model nepodporuje, zakomentuj riadok nižšie a nechaj respondentEmail = null.
    final respondentEmail = items.firstWhereOrNull((s) => true)?.assignedToEmail;

    final isVerified = items.any((s) => s.completedByUserId != null);
    final int completedCount = items.where((s) => s.isCompleted).length;

    final bool hasOverdue = items.any((s) => !s.isCompleted && s.deadline.isBefore(DateTime.now()));
    final isLate = isMainTaskOnly && firstItem.isCompleted && firstItem.completedAt != null && firstItem.completedAt!.isAfter(firstItem.deadline);

    // Zisťovanie farieb a statusov
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
    }

    // HLAVIČKA KARTY (Dizajn podľa obrázka)
    Widget headerContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AvatarCircle(name: respondentName),
        const SizedBox(width: 14),

        // Stredná časť: Meno, E-mail, Odznaky a Progress bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(respondentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                  // E-mail (ak existuje)
                  if (respondentEmail != null && respondentEmail.isNotEmpty)
                    Text("($respondentEmail)", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),

                  // Odznak: Verified
                  if (isVerified)
                    _PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),

                  // Odznak: Status (Overdue/Late/Complete)
                  if (statusLabel != null && statusColor != null)
                    _PillBadge(icon: statusIcon!, text: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar presne pod menom ako na obrázku
              if (!isMainTaskOnly)
                SegmentedProgressBar(green: completedCount, grey: totalTemplates - completedCount, height: 6),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Pravá časť: Skóre (4/6) alebo Čas splnenia
        if (!isMainTaskOnly) ...[
          Text(
              "$completedCount/$totalTemplates",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor // Zafarbí sa podľa toho či je to ok alebo overdue
              )
          ),
          const SizedBox(width: 8),
          Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: cs.onSurfaceVariant),
        ] else if (firstItem.isCompleted && firstItem.completedAt != null) ...[
          Text(
            DateFormat('dd.MM HH:mm').format(firstItem.completedAt!.toLocal()),
            style: TextStyle(fontSize: 12, color: progressColor, fontWeight: FontWeight.bold),
          ),
        ]
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withAlpha(100)),
      ),
      child: Column(
        children: [
          // Klikateľná hlavička
          InkWell(
            onTap: isMainTaskOnly ? null : () => onToggle(!isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: headerContent,
            ),
          ),

          // Animované rozbalenie subtaskov (nahrádza ExpansionTile)
          if (!isMainTaskOnly)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children: [
                  Divider(height: 1, color: cs.outlineVariant.withAlpha(100)),
                  ...items.map((s) => _TaskItemRow(subtask: s)),
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

// --- SHARED TASK CARD ---
class _SharedTaskCard extends StatelessWidget {
  final SubtaskCombinedListModel subtask;
  final bool isMainTaskOnly;

  const _SharedTaskCard({required this.subtask, this.isMainTaskOnly = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
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
                    decoration: (!isMainTaskOnly && subtask.isCompleted) ? TextDecoration.lineThrough : null,
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
                // Štítky a E-mail pre Shared Mode
                if (!isMainTaskOnly) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4, // Pridané pre prípad, že je email dlhý a musí sa zalomiť
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // 1. Verified Badge
                      if (subtask.completedByUserId != null)
                        _PillBadge(icon: Icons.shield_outlined, text: "Verified", color: Colors.blueAccent),

                      // 2. Email (vložený medzi badge a meno)
                      if (subtask.assignedToEmail != null && subtask.assignedToEmail!.isNotEmpty)
                        Text(
                          "(${subtask.assignedToEmail})",
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),

                      // 3. Respondent Name
                      Text(
                          subtask.respondentName ?? "Unknown",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                // Čas splnenia
                Text(
                  "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                  style: TextStyle(fontSize: 13, color: iconColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// --- ATOMICKÉ PRVKY ---

class _TaskItemRow extends StatelessWidget {
  final SubtaskCombinedListModel subtask;
  const _TaskItemRow({required this.subtask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: contentColor.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          "${isLate ? 'Overdue ' : ''}${DateFormat('dd.MM HH:mm').format(subtask.completedAt!.toLocal())}",
                          style: TextStyle(fontSize: 10, color: contentColor.withOpacity(0.8)),
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
      backgroundColor: Colors.blueAccent, // Modrá ako na tvojom obrázku
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// NOVÝ WIDGET: Moderný štítok "Pill Badge" presne podľa tvojho zadania
class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _PillBadge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // Jemné podfarbenie
        borderRadius: BorderRadius.circular(12), // Kapsulový tvar
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}