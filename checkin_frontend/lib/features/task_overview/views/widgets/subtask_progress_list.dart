import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/features/task_overview/views/widgets/subtask_progress_widgets/respondent_card.dart';
import 'package:checkin_frontend/features/task_overview/views/widgets/subtask_progress_widgets/shared_task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../core/shared_widgets/segmented_progress_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../core/utils/responsive.dart'; // Uprav cestu

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
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(color: cs.primary, width: 0.8),
      ),
      child: _buildContent(context, cs, isMobile),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs, bool isMobile) {
    if (widget.subtasks.isEmpty) return _buildEmptyState(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:[
        if (widget.subtaskMode == SubtaskMode.individual)
          _buildIndividualMode(context, cs, isMobile)
        else
          _buildSharedMode(context, cs, isMobile),
      ],
    );
  }

  // --- INDIVIDUAL MODE ---
  Widget _buildIndividualMode(BuildContext context, ColorScheme cs, bool isMobile) {
    final grouped = groupBy(widget.subtasks, (s) => s.responseGroupId);
    final groupIds = grouped.keys.map((e) => e.toString()).toList();
    final int respondentCount = grouped.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        if (isMobile) ...[
          Text("Individual Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Text("$respondentCount Respondents", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              if (!widget.isMainTaskOnly)
                Row(
                  children:[
                    IconButton(icon: const Icon(Icons.unfold_more, size: 20), onPressed: () => _setAllExpanded(true, groupIds)),
                    IconButton(icon: const Icon(Icons.unfold_less, size: 20), onPressed: () => _setAllExpanded(false, groupIds)),
                  ],
                ),
            ],
          ),
        ] else ...[
          Row(
            children:[
              Text("Individual Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
              const Spacer(),
              Text("$respondentCount Respondents", style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              if (!widget.isMainTaskOnly) ...[
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.unfold_more, size: 20), onPressed: () => _setAllExpanded(true, groupIds), tooltip: "Expand All"),
                IconButton(icon: const Icon(Icons.unfold_less, size: 20), onPressed: () => _setAllExpanded(false, groupIds), tooltip: "Collapse All"),
              ],
            ],
          ),
        ],
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          return RespondentCard(
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
  // --- SHARED MODE ---
  Widget _buildSharedMode(BuildContext context, ColorScheme cs, bool isMobile) {
    final displayTasks = widget.isMainTaskOnly
        ? widget.subtasks.where((s) => s.isCompleted).toList()
        : widget.subtasks;

    final int total = displayTasks.length;

    final int onTimeCount = displayTasks.where((s) =>
    s.isCompleted && (s.completedAt == null || !s.completedAt!.isAfter(s.deadline))
    ).length;

    final int lateCount = displayTasks.where((s) =>
    s.isCompleted && s.completedAt != null && s.completedAt!.isAfter(s.deadline)
    ).length;

    final int remaining = total - (onTimeCount + lateCount);

    final int completedTotal = onTimeCount + lateCount;
    final int percent = total > 0 ? ((completedTotal / total) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                widget.isMainTaskOnly ? "Signatures / Completions" : "Shared Progress",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ),
            if (!widget.isMainTaskOnly)
              Text(
                  "$completedTotal/$total ($percent%)",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: lateCount > 0 && onTimeCount == 0 ? Colors.red : cs.primary
                  )
              ),
          ],
        ),

        if (!widget.isMainTaskOnly) ...[
          const SizedBox(height: 8),
          // POUŽITIE NOVÝCH FARIEB
          SegmentedProgressBar(
              green: onTimeCount,
              red: lateCount,     // Červená pre tie, čo sú neskoro
              grey: remaining,
              height: 12
          ),
        ],

        const SizedBox(height: 24),
        if (displayTasks.isEmpty && widget.isMainTaskOnly)
          _buildEmptyState(cs)
        else
          ...displayTasks.map((s) => SharedTaskCard(subtask: s, isMainTaskOnly: widget.isMainTaskOnly)),
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}