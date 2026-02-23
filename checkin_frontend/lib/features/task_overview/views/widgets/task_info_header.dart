import 'package:checkin_frontend/core/shared_widgets/date_display.dart';
import 'package:flutter/material.dart';

class TaskInfoHeader extends StatelessWidget {
  final DateTime createdDate;
  final DateTime deadlineDate;
  final bool requiresAuth;

  const TaskInfoHeader({
    super.key,
    required this.createdDate,
    required this.deadlineDate,
    required this.requiresAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Colors.blue.shade300, width: 1),
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: SelectionArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deadline", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DateDisplay(dateTime: deadlineDate, icon: Icons.alarm),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Created On", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DateDisplay(
                  dateTime: createdDate,
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
        
                Text("TODO"),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Identity Verification",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      requiresAuth ? Icons.verified_user : Icons.no_encryption_outlined,
                      size: 16,
                      color: requiresAuth ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      requiresAuth
                          ? "Required"
                          : "Not Required", // "Required" znie lepšie ako "Enabled"
                      style: TextStyle(
                        color: requiresAuth ? Colors.blue.shade700 : Colors.grey.shade600,
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
