import 'package:checkin_frontend/core/shared_widgets/date_display.dart';
import 'package:flutter/material.dart';

class TaskInfoHeader extends StatefulWidget {
  final DateTime createdDate;
  final DateTime deadlineDate;
  final DateTime lastModified;
  final bool requiresAuth;
  final VoidCallback? onDeadlineTap;

  const TaskInfoHeader({
    super.key,
    required this.createdDate,
    required this.deadlineDate,
    required this.requiresAuth,
    required this.lastModified,
    this.onDeadlineTap,
  });

  @override
  State<TaskInfoHeader> createState() => _TaskInfoHeaderState();
}

class _TaskInfoHeaderState extends State<TaskInfoHeader> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withAlpha(125)),
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: SelectionArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: widget.onDeadlineTap,
              onHover: (hovering) {
                setState(() {
                  _isHovering = hovering;
                });
              },
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(8),
              hoverColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: _isHovering ? colorScheme.primary.withAlpha(25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isHovering ? colorScheme.primary.withAlpha(100) : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Deadline",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isHovering ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: _isHovering
                              ? colorScheme.primary
                              : colorScheme.primary.withAlpha(150),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    DateDisplay(dateTime: widget.deadlineDate, icon: Icons.alarm),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Created On",
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 6),
                DateDisplay(
                  dateTime: widget.createdDate,
                  icon: Icons.calendar_today,
                  color: Colors.grey,
                  showRelative: false,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Last Modified", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DateDisplay(
                  dateTime: widget.lastModified,
                  icon: Icons.edit,
                  color: Colors.grey,
                  showRelative: false,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Identity Verification", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      widget.requiresAuth ? Icons.verified_user : Icons.no_encryption_outlined,
                      size: 16,
                      color: widget.requiresAuth ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.requiresAuth
                          ? "Required"
                          : "Not Required", // "Required" znie lepšie ako "Enabled"
                      style: TextStyle(
                        color: widget.requiresAuth
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
