import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/invitations/invitation_list_model.dart';
import '../../../../core/models/task/task_detail_model.dart';
import '../../../../core/models/task/task_update_model.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';

// --- IMPORT PRE RESPONSIVE ---
import '../../../../core/utils/responsive.dart'; // Uprav cestu ak treba

enum EditToolbarState { none, defaultEdit, addMode, removeMode }

class TaskInvitedUsersWidget extends ConsumerStatefulWidget {
  final TaskDetailModel task;

  const TaskInvitedUsersWidget({
    super.key,
    required this.task
  });

  @override
  ConsumerState<TaskInvitedUsersWidget> createState() => _TaskInvitedUsersWidgetState();
}

class _TaskInvitedUsersWidgetState extends ConsumerState<TaskInvitedUsersWidget> {
  EditToolbarState _toolbarState = EditToolbarState.none;
  bool _isProcessing = false;
  bool _cooldownActive = false;
  final List<String> _selectedEmails =[];
  final _emailInputController = TextEditingController();

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(taskDetailProvider(widget.task.id));
    ref.invalidate(taskInvitationsProvider(widget.task.id));
    ref.invalidate(taskInstancesProvider(widget.task.id));
  }

  void _startCooldown() {
    setState(() => _cooldownActive = true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _cooldownActive = false);
    });
  }

  Future<void> _handleInviteAll() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(invitationApiServiceProvider).sendInvitations(widget.task.id, null);
      AppSnackBar.showInfo(context, context.l10n.overview_invite_sending_msg);
      _startCooldown();
    } catch (e) {
      AppSnackBar.showError(context, "Failed to send invitations.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleNotifyPending() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(invitationApiServiceProvider).sendReminders(widget.task.id);
      AppSnackBar.showInfo(context, "Sending reminders...");
      _startCooldown();
    } catch (e) {
      AppSnackBar.showError(context, "Failed to send reminders.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleParseAndAdd() async {
    final rawText = _emailInputController.text.trim();
    if (rawText.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final List<String> newEmails = await ref
          .read(invitationApiServiceProvider)
          .parseEmails('"$rawText"');
      if (newEmails.isEmpty) {
        AppSnackBar.showInfo(context, "No valid new emails found.");
        return;
      }
      final updatedEmailList = {...widget.task.invitations.map((e) => e.email), ...newEmails}.toList();

      // ===== TOTO JE TÁ ZÁSADNÁ OPRAVA =====
      // Posielame späť VŠETKY staré dáta, aby ich backend nezmazal!
      final updateModel = TaskUpdateModel(
        id: widget.task.id,
        title: widget.task.title,
        notes: widget.task.notes, // Udrží poznámky
        deadLine: widget.task.deadLine,
        requiresAuthenticationToComplete: widget.task.requiresAuthenticationToComplete, // Udrží Auth status
        allowedDomain: widget.task.allowedDomain, // Udrží doménu
        state: widget.task.state, // Udrží stav
        invitedEmails: updatedEmailList,
      );
      // ======================================

      await ref.read(taskApiServiceProvider).updateTask(widget.task.id, updateModel);
      _emailInputController.clear();
      setState(() => _toolbarState = EditToolbarState.defaultEdit);
      _refreshAll();
    } catch (e) {
      AppSnackBar.showError(context, "Failed to add emails.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleBulkDelete() async {
    if (_selectedEmails.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      await ref.read(taskApiServiceProvider).removeInvitations(widget.task.id, _selectedEmails);
      setState(() {
        _selectedEmails.clear();
        _toolbarState = EditToolbarState.defaultEdit;
      });
      _refreshAll();
    } catch (e) {
      AppSnackBar.showError(context, "Failed to remove emails.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSingleDelete(String email) async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(taskApiServiceProvider).removeInvitations(widget.task.id, [email]);
      _refreshAll();
      if (mounted) {
        AppSnackBar.showSuccess(context, "Invitation for $email removed");
      }
    } catch (e) {
      AppSnackBar.showError(context, "Failed to delete.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;
    final bool isEditMode = _toolbarState != EditToolbarState.none;

    final int totalInvited = widget.task.invitations.length;
    final int completed = widget.task.invitations.where((i) => i.isAccepted).length;
    final bool hasUnsent = widget.task.invitations.any((i) => !i.isSent);
    final bool hasUnfinished = widget.task.invitations.any((i) => i.isSent && !i.isAccepted);

    return Container(
      // NA MOBILE ZMENŠENÝ PADDING PRE VIAC PRIESTORU
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          // --- ROW 1: HEADER (RESPONZÍVNY) ---
          _buildHeader(cs, isMobile, isEditMode, totalInvited, completed, hasUnfinished, hasUnsent),

          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outlineVariant),

          // --- ROW 2: EDIT TOOLBAR ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildToolbar(cs, isMobile),
          ),

          const SizedBox(height: 16),

          // --- ROW 3: CHIPS ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.task.invitations.map((inv) => _buildChip(inv, cs)).toList(),
          ),
        ],
      ),
    );
  }

  // --- ODDELENÁ LOGIKA PRE HLAVIČKU ---
  Widget _buildHeader(ColorScheme cs, bool isMobile, bool isEditMode, int totalInvited, int completed, bool hasUnfinished, bool hasUnsent) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:[
              Icon(Icons.people_outline, size: 20, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                "Invited",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(
                      () => _toolbarState = isEditMode ? EditToolbarState.none : EditToolbarState.defaultEdit,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  isEditMode ? "Done" : "Edit",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            "$totalInvited Invited • $completed Completed",
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children:[
              Expanded(
                child: Tooltip(
                  message: "Sends a reminder to everyone who received the invitation but hasn't completed the task yet.",
                  child: _ActionBtn(
                    label: "Remind",
                    icon: Icons.notification_important_outlined,
                    iconColor: Colors.orange,
                    fullWidth: true, // Roztiahne na celú šírku Expanded
                    onPressed: (hasUnfinished && !_cooldownActive && !_isProcessing) ? _handleNotifyPending : null,
                    isPrimary: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: "Sends invitations to people who haven't been invited yet.",
                  child: _ActionBtn(
                    label: "Invite New",
                    icon: Icons.mail_outline,
                    iconColor: Colors.white,
                    fullWidth: true, // Roztiahne na celú šírku Expanded
                    onPressed: (hasUnsent && !_cooldownActive && !_isProcessing) ? _handleInviteAll : null,
                    isPrimary: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // DESKTOP VERZIA
      return Row(
        children:[
          Icon(Icons.people_outline, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            "Invited",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => setState(
                  () => _toolbarState = isEditMode ? EditToolbarState.none : EditToolbarState.defaultEdit,
            ),
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              isEditMode ? "Done" : "Edit",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$totalInvited Invited • $completed Completed",
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          Tooltip(
            message: "Sends a reminder to everyone who received the invitation but hasn't completed the task yet.",
            child: _ActionBtn(
              label: "Remind Unfinished",
              icon: Icons.notification_important_outlined,
              iconColor: Colors.orange,
              onPressed: (hasUnfinished && !_cooldownActive && !_isProcessing) ? _handleNotifyPending : null,
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: "Sends invitations to people who haven't been invited yet.",
            child: _ActionBtn(
              label: "Invite New",
              icon: Icons.mail_outline,
              iconColor: Colors.white,
              onPressed: (hasUnsent && !_cooldownActive && !_isProcessing) ? _handleInviteAll : null,
              isPrimary: true,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildToolbar(ColorScheme cs, bool isMobile) {
    switch (_toolbarState) {
      case EditToolbarState.defaultEdit:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          key: const ValueKey('defaultEdit'),
          child: Row(
            children:[
              _ToolbarBtn(
                label: "Add Emails",
                icon: Icons.add,
                onTap: () => setState(() => _toolbarState = EditToolbarState.addMode),
              ),
              const SizedBox(width: 8),
              _ToolbarBtn(
                label: isMobile ? "Remove" : "Select to Remove",
                icon: Icons.delete_outline,
                onTap: () => setState(() => _toolbarState = EditToolbarState.removeMode),
              ),
            ],
          ),
        );
      case EditToolbarState.addMode:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          key: const ValueKey('addMode'),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              _buildEmailInput(cs),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  TextButton(
                    onPressed: () => setState(() => _toolbarState = EditToolbarState.defaultEdit),
                    child: Text("Cancel", style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handleParseAndAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 0,
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
            ],
          )
              : Row(
            children:[
              Expanded(child: _buildEmailInput(cs)),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isProcessing ? null : _handleParseAndAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  elevation: 0,
                ),
                child: const Text("Add"),
              ),
              TextButton(
                onPressed: () => setState(() => _toolbarState = EditToolbarState.defaultEdit),
                child: Text("Cancel", style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            ],
          ),
        );
      case EditToolbarState.removeMode:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          key: const ValueKey('removeMode'),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text(
                _selectedEmails.isEmpty
                    ? "Click chips to select for deletion"
                    : "${_selectedEmails.length} selected",
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedEmails.isEmpty ? cs.onSurfaceVariant : cs.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedEmails.clear();
                        _toolbarState = EditToolbarState.defaultEdit;
                      });
                    },
                    child: Text("Cancel", style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                  if (_selectedEmails.isNotEmpty)
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _handleBulkDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                        elevation: 0,
                      ),
                      child: const Text("Confirm Delete"),
                    ),
                ],
              ),
            ],
          )
              : Row(
            children:[
              Text(
                _selectedEmails.isEmpty
                    ? "Click chips to select for deletion"
                    : "${_selectedEmails.length} selected",
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedEmails.isEmpty ? cs.onSurfaceVariant : cs.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_selectedEmails.isNotEmpty)
                ElevatedButton(
                  onPressed: _isProcessing ? null : _handleBulkDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                    elevation: 0,
                  ),
                  child: const Text("Confirm Delete"),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedEmails.clear();
                    _toolbarState = EditToolbarState.defaultEdit;
                  });
                },
                child: Text("Cancel", style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailInput(ColorScheme cs) {
    return TextField(
      controller: _emailInputController,
      autofocus: true,
      onSubmitted: (_) => _handleParseAndAdd(),
      decoration: InputDecoration(
        hintText: "Enter emails...",
        isDense: true,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
      ),
    );
  }

  Widget _buildChip(InvitationListModel inv, ColorScheme cs) {
    final bool isRemoveMode = _toolbarState == EditToolbarState.removeMode;
    final bool isDefaultEdit = _toolbarState == EditToolbarState.defaultEdit;
    final bool isSelected = _selectedEmails.contains(inv.email);

    Color bgColor = cs.surfaceContainerHigh;
    Color textColor = cs.onSurfaceVariant;
    IconData icon = Icons.circle_outlined;

    if (inv.isSent) {
      bgColor = cs.primary.withAlpha(25);
      textColor = cs.primary;
      icon = Icons.send_rounded;
    }
    if (inv.isAccepted) {
      bgColor = Colors.indigo.withAlpha(25);
      textColor = Colors.indigo[700]!;
      icon = Icons.visibility_outlined;
    }
    if (inv.isCompleted) {
      bgColor = Colors.green.withAlpha(25);
      textColor = Colors.green[700]!;
      icon = Icons.check_circle_outline;
    }

    if (isRemoveMode && isSelected) {
      bgColor = cs.errorContainer;
      textColor = cs.onErrorContainer;
    }

    return GestureDetector(
      onTap: isRemoveMode
          ? () => setState(
            () => isSelected ? _selectedEmails.remove(inv.email) : _selectedEmails.add(inv.email),
      )
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRemoveMode && isSelected ? cs.error : Colors.transparent,
            width: isRemoveMode && isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            SelectionArea(
              child: Text(
                inv.email,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isDefaultEdit) ...[
              const SizedBox(width: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleSingleDelete(inv.email),
                  borderRadius: BorderRadius.circular(100),
                  hoverColor: cs.error.withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 16, color: cs.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? iconColor;
  final bool fullWidth; // Nové pole pre podporu natiahnutia do šírky na mobile

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
    this.iconColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final effectiveIconColor = onPressed == null ? null : iconColor;

    final style = isPrimary
        ? ElevatedButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 0,
    )
        : ElevatedButton.styleFrom(
      backgroundColor: cs.surfaceContainerHigh,
      foregroundColor: cs.onSurfaceVariant,
      elevation: 0,
    );

    Widget btn = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: effectiveIconColor),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        maxLines: 1, // Zabráni zalomeniu, ak je telefón malý
        overflow: TextOverflow.ellipsis,
      ),
      style: style,
    );

    // Ak je fullWidth nastavené na true, roztiahne sa naplno do šírky rodiča
    if (fullWidth) {
      btn = SizedBox(width: double.infinity, child: btn);
    }

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: btn,
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        // Mierne zmenšený horizontálny padding
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            Icon(icon, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}