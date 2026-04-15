import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/invitations/invitation_list_model.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/utils/app_snack_bar.dart';

class TaskInvitedUsersWidget extends ConsumerStatefulWidget {
  final String taskId; // Potrebujeme ID pre API call
  final List<InvitationListModel> invitations;

  const TaskInvitedUsersWidget({
    super.key,
    required this.taskId,
    required this.invitations
  });

  @override
  ConsumerState<TaskInvitedUsersWidget> createState() => _TaskInvitedUsersWidgetState();
}

class _TaskInvitedUsersWidgetState extends ConsumerState<TaskInvitedUsersWidget> {
  bool _isSending = false;
  bool _cooldownActive = false;

  // SPAM PREVENTION LOGIKA:
  // 1. Tlačidlo sa zobrazí len ak sú nejakí ľudia, ktorí ešte neprijali pozvánku
  // 2. Po kliknutí sa spustí loading a následne cooldown
  Future<void> _handleSendInvites() async {
    setState(() => _isSending = true);

    try {
      await ref.read(invitationApiServiceProvider).sendPendingInvitations(widget.taskId);

      if (mounted) {
        AppSnackBar.showSuccess(context, "Invitations sent successfully!");
        setState(() {
          _isSending = false;
          _cooldownActive = true;
        });

        // Cooldown na 30 sekúnd, aby sa nedalo klikať opakovane
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted) setState(() => _cooldownActive = false);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Failed to send invitations.");
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.invitations.isEmpty) return const SizedBox.shrink();

    // Zistíme, či má zmysel posielať maily (sú tam neprijaté pozvánky?)
    final hasPending = widget.invitations.any((inv) => !inv.isAccepted);

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
            // HEADER S TLAČIDLOM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.mail_outline, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Invited People (${widget.invitations.length})",
                      style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                  ],
                ),
                // TLAČIDLO "SEND INVITES"
                if (hasPending)
                  TextButton.icon(
                    onPressed: (_isSending || _cooldownActive) ? null : _handleSendInvites,
                    icon: _isSending
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.send, size: 14, color: _cooldownActive ? cs.outline : cs.primary),
                    label: Text(
                      _cooldownActive ? "Wait 30s" : "Send Invites",
                      style: TextStyle(
                          fontSize: 12,
                          color: (_isSending || _cooldownActive) ? cs.outline : cs.primary,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ZOZNAM ČIPOV
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.invitations.map((inv) {
                final accepted = inv.isAccepted;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: accepted ? Colors.green.withAlpha(25) : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accepted ? Colors.green : cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        accepted ? Icons.check_circle : Icons.hourglass_empty,
                        size: 14,
                        color: accepted ? Colors.green : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        inv.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: accepted ? Colors.green[700] : cs.onSurface,
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