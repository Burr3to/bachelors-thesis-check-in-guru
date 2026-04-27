import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/invitations/invitation_list_model.dart';
import '../../../../core/models/task/task_update_model.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';

class TaskInvitedUsersWidget extends ConsumerStatefulWidget {
  final String taskId;
  final String taskTitle;
  final DateTime taskDeadline;
  final List<InvitationListModel> invitations;

  const TaskInvitedUsersWidget({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.taskDeadline,
    required this.invitations,
  });

  @override
  ConsumerState<TaskInvitedUsersWidget> createState() => _TaskInvitedUsersWidgetState();
}

class _TaskInvitedUsersWidgetState extends ConsumerState<TaskInvitedUsersWidget> {
  bool _isSending = false;
  bool _isParsing = false;
  bool _isDeleting = false;
  bool _cooldownActive = false;
  bool _showInput = false;
  bool _isRemoving = false;

  final List<String> _selectedEmails = [];
  final _emailInputController = TextEditingController();

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(taskDetailProvider(widget.taskId));
    ref.invalidate(taskInvitationsProvider(widget.taskId));
    ref.invalidate(taskInstancesProvider(widget.taskId));
  }

  /// POSLANIE NOVÝM (isSent == false)
  Future<void> _handleSendToNew() async {
    setState(() => _isSending = true);
    try {
      await ref.read(invitationApiServiceProvider).sendInvitations(widget.taskId, null);
      if (mounted) {
        AppSnackBar.showInfo(context, context.l10n.overview_invite_sending_msg);
        _startCooldown();
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, context.l10n.overview_invite_err_sending);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// POSLANIE PRIPOMIENOK (isAccepted == false)
  Future<void> _handleRemindPending() async {
    setState(() => _isSending = true);
    try {
      await ref.read(invitationApiServiceProvider).sendReminders(widget.taskId);
      if (mounted) {
        AppSnackBar.showInfo(context, "Sending reminders in background...");
        _startCooldown();
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Failed to start reminders.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startCooldown() {
    setState(() => _cooldownActive = true);
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _cooldownActive = false);
    });
  }

  Future<void> _handleDeleteConfirm() async {
    if (_selectedEmails.isEmpty) return;
    setState(() => _isDeleting = true);
    try {
      await ref.read(taskApiServiceProvider).removeInvitations(widget.taskId, _selectedEmails);
      if (mounted) {
        AppSnackBar.showSuccess(context,context.l10n.overview_invite_removed_msg(_selectedEmails.length));
        setState(() {
          _isRemoving = false;
          _selectedEmails.clear();
          _isDeleting = false;
        });
        _refreshAll();
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Failed to remove people.");
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _handleParseAndAdd() async {
    final rawText = _emailInputController.text.trim();
    if (rawText.isEmpty) return;
    setState(() => _isParsing = true);
    try {
      final List<String> newEmails = await ref
          .read(invitationApiServiceProvider)
          .parseEmails('"$rawText"');
      if (newEmails.isEmpty) {
        if (mounted) AppSnackBar.showInfo(context, context.l10n.overview_invite_no_new_emails);
        setState(() => _isParsing = false);
        return;
      }
      final existingEmails = widget.invitations.map((e) => e.email).toList();
      final updatedEmailList = {...existingEmails, ...newEmails}.toList();

      final updateModel = TaskUpdateModel(
        id: widget.taskId,
        title: widget.taskTitle,
        deadLine: widget.taskDeadline,
        invitedEmails: updatedEmailList,
      );

      await ref.read(taskApiServiceProvider).updateTask(widget.taskId, updateModel);
      if (mounted) {
        AppSnackBar.showSuccess(context, context.l10n.overview_invite_added_msg(newEmails.length));
        _emailInputController.clear();
        setState(() {
          _showInput = false;
          _isParsing = false;
        });
        _refreshAll();
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Failed to add people.");
      setState(() => _isParsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Smart logika pre tlačidlá
    final bool hasUnsent = widget.invitations.any((inv) => !inv.isSent);
    final bool hasNotAccepted = widget.invitations.any((inv) => inv.isSent && !inv.isAccepted);

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
                Icon(Icons.people_outline, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  context.l10n.overview_invite_title(widget.invitations.length),
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const SizedBox(width: 16),

                if (!_isRemoving && !_showInput) ...[
                  // ADD Button
                  TextButton(
                    onPressed: () => setState(() => _showInput = true),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(
                      context.l10n.common_add,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // REMOVE Button
                  TextButton(
                    onPressed: () => setState(() => _isRemoving = true),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(
                      context.l10n.overview_invite_remove,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],

                if (_showInput)
                  TextButton(
                    onPressed: () => setState(() => _showInput = false),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(
                      context.l10n.common_cancel,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.error),
                    ),
                  ),

                if (_isRemoving) ...[
                  TextButton(
                    onPressed: () => setState(() {
                      _isRemoving = false;
                      _selectedEmails.clear();
                    }),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_selectedEmails.isEmpty || _isDeleting)
                        ? null
                        : _handleDeleteConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.onError,
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: _isDeleting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                      context.l10n.overview_invite_delete_count(_selectedEmails.length),
                            style: const TextStyle(fontSize: 11),
                          ),
                  ),
                ],

                const Spacer(),

                // SMART SEND BUTTONS
                if (!_isRemoving && !_showInput && !_cooldownActive && !_isSending) ...[
                  if (hasUnsent)
                    TextButton.icon(
                      onPressed: _handleSendToNew,
                      icon: const Icon(Icons.send, size: 14),
                      label: Text(context.l10n.overview_invite_btn_send_new, style: const TextStyle(fontSize: 13)),
                    ),
                  if (hasUnsent && hasNotAccepted) const SizedBox(width: 8),
                  if (hasNotAccepted) // Ak už sú všetci aspoň raz poslaní, ukáž Remind
                    TextButton.icon(
                      onPressed: _handleRemindPending,
                      icon: const Icon(Icons.notification_important_outlined, size: 14),
                      label: Text(context.l10n.overview_invite_btn_remind, style: const TextStyle(fontSize: 13)),
                    ),
                ] else if (_cooldownActive)
                  Text(context.l10n.overview_invite_cooldown, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            if (_showInput) ...[
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailInputController,
                        onSubmitted: (_) => _isParsing ? null : _handleParseAndAdd(),
                        decoration: InputDecoration(
                          hintText: context.l10n.overview_invite_input_hint,
                          isDense: true,
                          filled: true,
                          fillColor: cs.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isParsing ? null : _handleParseAndAdd,
                      child: _isParsing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Add"),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // CHIPS LIST
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.invitations.map((inv) {
                final bool isSelected = _selectedEmails.contains(inv.email);

                // LOGIKA FARIEB A IKONIEK
                Color contentColor = cs.onSurfaceVariant;
                Color chipColor = cs.surface;
                IconData icon = Icons.circle_outlined;

                if (inv.isAccepted) {
                  contentColor = isDark ? Colors.greenAccent : Colors.green[700]!;
                  chipColor = Colors.green.withAlpha(25);
                  icon = Icons.check_circle;
                } else if (inv.isSent) {
                  contentColor = cs.primary;
                  chipColor = cs.primary.withAlpha(25);
                  icon = Icons.mark_email_unread_outlined;
                }

                if (_isRemoving && isSelected) {
                  contentColor = cs.error;
                  chipColor = cs.error.withAlpha(isDark ? 40 : 25);
                  icon = Icons.delete_forever;
                }

                return InkWell(
                  onTap: _isRemoving
                      ? () {
                          setState(() {
                            isSelected
                                ? _selectedEmails.remove(inv.email)
                                : _selectedEmails.add(inv.email);
                          });
                        }
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isSelected && _isRemoving)
                            ? cs.error
                            : (inv.isAccepted || inv.isSent ? contentColor : cs.outlineVariant),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18, color: contentColor),
                        const SizedBox(width: 6),
                        Text(
                          inv.email,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
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
