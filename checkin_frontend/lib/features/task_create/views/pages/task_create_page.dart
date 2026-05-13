import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/providers/task_create/task_create_provider.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/shared_widgets/invalid_emails_dialog.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/quill_utils.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/subtask_input_section.dart';
import '../widgets/task_basic_info.dart';
import '../widgets/task_invite_section.dart';
import '../widgets/task_settings_section.dart';

/// Page responsible for creating a new task, managing its basic info,
/// invitations, subtasks, and settings.
class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  bool _inviteExpanded = false;
  bool _subtasksExpanded = false;
  bool _isLoading = false;
  late SignalRService _signalRService;

  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _quillCtrl = QuillController.basic();
    _signalRService = ref.read(signalRProvider);

    // Initialize SignalR listeners and room joining after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });

    // Sync UI controllers with the underlying Riverpod state
    _titleCtrl.addListener(() {
      ref.read(taskCreateProvider.notifier).updateTitle(_titleCtrl.text);
    });

    _quillCtrl.changes.listen((_) {
      final isEditorEmpty =
          _quillCtrl.document.isEmpty() || _quillCtrl.document.toPlainText().trim().isEmpty;

      // Convert Delta to JSON string only if content exists
      final notes = !isEditorEmpty ? QuillUtils.controllerToString(_quillCtrl) : null;
      ref.read(taskCreateProvider.notifier).updateDescription(notes);
    });
  }

  /// Sets up real-time communication to receive notifications about invalid emails
  /// or background processing results.
  void _setupSignalR() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    await _signalRService.joinUserRoom(user.userId);
    _signalRService.connection?.on("InvalidEmailsFound", _handleInvalidEmails);
  }

  /// Displays a dialog if the backend identifies malformed or invalid email addresses.
  void _handleInvalidEmails(List<Object?>? arguments) {
    final rawList = arguments?[0] as List?;
    if (rawList == null) return;

    final invalidEmails = rawList.map((e) => e.toString()).toList();
    if (invalidEmails.isNotEmpty) {
      Future.microtask(() {
        if (mounted) {
          InvalidEmailsDialog.show(context, invalidEmails);
        }
      });
    }
  }

  /// Utility to set the time of a given date to the very end of that day.
  DateTime _normalizeToEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    _signalRService.connection?.off("InvalidEmailsFound", method: _handleInvalidEmails);
    super.dispose();
  }

  /// Validates input and submits the task creation request to the API.
  Future<void> _handleCreateTask() async {
    final taskData = ref.read(taskCreateProvider);

    // Basic client-side validation
    if (taskData.title.isEmpty || taskData.deadLine == null) {
      AppSnackBar.showInfo(context, context.l10n.task_create_err_required);
      return;
    }

    // Handle domain validation warnings for restricted tasks
    if (taskData.requiresAuthenticationToComplete &&
        taskData.allowedDomain != null &&
        taskData.isDomainValid == false) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Domain Warning"),
          content: Text(
            "We couldn't verify that '${taskData.allowedDomain}' is a valid mail domain."
                " If it's incorrect, invited respondents won't be able to access the task. Do you want to proceed anyway?",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("PROCEED", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final createdTask = await ref.read(taskApiServiceProvider).createTask(taskData);

      if (mounted) {
        // Refresh the task list and navigate to the newly created task overview
        ref.invalidate(taskListProvider);
        context.go('/tasks/${createdTask.id}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, "Error creating task: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = context.isMobile;

    // Responsive width calculation for the main form container
    double contentWidth;
    if (screenWidth < 600) {
      contentWidth = screenWidth;
    } else if (screenWidth < 1200) {
      contentWidth = 700;
    } else {
      contentWidth = 800;
    }

    final deadline = ref.watch(taskCreateProvider.select((s) => s.deadLine));
    final requiresAuth = ref.watch(taskCreateProvider.select((s) => s.requiresAuthenticationToComplete));
    final mode = ref.watch(taskCreateProvider.select((s) => s.subtaskMode));
    final notifier = ref.read(taskCreateProvider.notifier);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: isMobile ? 16 : 40,
          bottom: 20,
          left: isMobile ? 0 : 16,
          right: isMobile ? 0 : 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                  child: _buildHeader(cs, isMobile),
                ),
                SizedBox(height: isMobile ? 16 : 24),

                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                    border: isMobile
                        ? Border.symmetric(
                      horizontal: BorderSide(color: cs.outlineVariant.withAlpha(100), width: 1),
                    )
                        : Border.all(color: cs.outlineVariant.withAlpha(125)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section for Title and Rich Text description
                      TaskBasicInfo(titleController: _titleCtrl, quillController: _quillCtrl),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),

                      Column(
                        children: [
                          // Section for adding participants/emails
                          if (!_inviteExpanded)
                            _CollapsedButton(
                              icon: Icons.person_add_alt_1,
                              label: context.l10n.task_create_btn_invite,
                              onTap: () => setState(() => _inviteExpanded = true),
                            )
                          else
                            TaskInviteSection(
                              isExpanded: true,
                              onEmailsChanged: notifier.setEmails,
                              onCollapse: () => setState(() => _inviteExpanded = false),
                            ),

                          const SizedBox(height: 12),

                          // Section for defining subtasks
                          if (!_subtasksExpanded)
                            _CollapsedButton(
                              icon: Icons.list_alt,
                              label: context.l10n.task_create_btn_subtasks,
                              onTap: () => setState(() => _subtasksExpanded = true),
                            )
                          else
                            SubtaskInputSection(
                              key: const ValueKey('subtask_section'),
                              onRemoveSection: () => setState(() => _subtasksExpanded = false),
                            ),
                        ],
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

                      // Global task configuration (Deadline, Auth, Mode)
                      TaskSettingsSection(
                        selectedDeadline: deadline,
                        requiresAuth: requiresAuth,
                        currentMode: mode,
                        onDomainChanged: (domain) {
                          ref.read(taskCreateProvider.notifier).updateAllowedDomain(domain);
                        },
                        onDateTap: () async {
                          // Date selection
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: deadline.toLocal(),
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            if (!context.mounted) return;

                            // Time selection with 24h format support
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(deadline.toLocal()),
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedTime != null) {
                              // Combine and store in UTC
                              final finalDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              notifier.setDeadline(finalDateTime.toUtc());
                            }
                          }
                        },
                        onAuthChanged: notifier.toggleAuth,
                        onModeChanged: notifier.setSubtaskMode,
                        onDateQuickSelect: (date) {
                          final endOfDay = _normalizeToEndOfDay(date);
                          notifier.setDeadline(endOfDay.toUtc());
                        },
                      ),

                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),

                      PrimaryButton(
                        text: context.l10n.task_create_btn_create,
                        isLoading: _isLoading,
                        onPressed: _handleCreateTask,
                      ),

                      if (isMobile) const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a responsive header with breadcrumbs for mobile and a full title for desktop.
  Widget _buildHeader(ColorScheme cs, bool isMobile) {
    if (isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) context.pop();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    "Back",
                    style: TextStyle(color: cs.primary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text("/", style: TextStyle(color: cs.onSurfaceVariant.withAlpha(120), fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.task_create_header_title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.task_create_header_title,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.task_create_header_subtitle,
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// A simplified button widget for optional expandable sections.
class _CollapsedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CollapsedButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: context.isMobile ? 12 : 16,
            horizontal: 16
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    context.l10n.task_create_optional,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.add, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}