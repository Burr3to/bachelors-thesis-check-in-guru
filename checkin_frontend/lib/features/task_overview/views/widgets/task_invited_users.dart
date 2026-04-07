import 'package:flutter/material.dart';

import '../../../../core/models/invitations/invitation_list_model.dart';

class TaskInvitedUsersWidget extends StatelessWidget {
  final List<InvitationListModel> invitations;

  const TaskInvitedUsersWidget({super.key, required this.invitations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (invitations.isEmpty) {
      return const SizedBox.shrink(); // Ak nikto nie je pozvaný, nezobrazuj nič
    }

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  "Invited People (${invitations.length})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: invitations.map((inv) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: inv.isAccepted
                        ? Colors.green.withOpacity(0.1)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: inv.isAccepted ? Colors.green : cs.outlineVariant
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        inv.isAccepted ? Icons.check_circle : Icons.hourglass_empty,
                        size: 14,
                        color: inv.isAccepted ? Colors.green : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        inv.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: inv.isAccepted ? Colors.green[700] : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}