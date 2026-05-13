import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/enums/task_enums.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/models/task/task_update_model.dart';
import '../../../../core/providers/invitation_providers.dart';
import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/shared_widgets/invalid_emails_dialog.dart';
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/models/task/task_detail_model.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/editable_task_notes.dart';
import '../widgets/editable_task_title.dart';
import '../widgets/subtask_list_section.dart';
import '../widgets/subtask_progress_list.dart';
import '../widgets/task_overview_header.dart';
import '../widgets/task_invited_users.dart';

/// The main management page for a specific task.
/// Provides functionality for editing details, managing subtasks,
/// tracking progress, and handling invitations with real-time updates.
class TaskOverviewPage extends ConsumerStatefulWidget {
  final String taskId;
  const TaskOverviewPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskOverviewPage> createState() => _TaskOverviewPageState();
}

class _TaskOverviewPageState extends ConsumerState<TaskOverviewPage> {
  late SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = ref.read(signalRProvider);

    // Defer SignalR initialization to ensure context and providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });
  }

  /// Refreshes task and invitation data when the server signals a change.
  void _handleInvitationsChanged(List<Object?>? arguments) {
    if (!mounted) return;
    ref.invalidate(taskDetailProvider(widget.taskId));
    ref.invalidate(taskInvitationsProvider(widget.taskId));
  }

  /// Refreshes execution progress and global stats when subtasks are completed.
  void _handleInstancesChanged(List<Object?>? arguments) {
    if (!mounted) return;
    ref.invalidate(taskInstancesProvider(widget.taskId));
    ref.invalidate(allTaskStatsProvider);
  }

  /// Shows a specialized dialog if batch-invited emails were found invalid.
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

  /// Configures SignalR subscriptions and joins relevant communication rooms.
  void _setupSignalR() async {
    final user = ref.read(authProvider).user;
    final roomName = widget.taskId.toLowerCase().trim();

    // Join the specific room for this task's updates
    await _signalRService.joinTaskRoom(roomName);

    // Join the user-specific room for private background notifications
    if (user != null) {
      await _signalRService.joinUserRoom(user.userId);
    }

    // Map server-side hub methods to local handlers
    _signalRService.connection?.on("TaskInstancesChanged", _handleInstancesChanged);
    _signalRService.connection?.on("TaskInvitationsChanged", _handleInvitationsChanged);
    _signalRService.connection?.on("InvalidEmailsFound", _handleInvalidEmails);
    _signalRService.connection?.on("ReceiveNotification", _handleGlobalNotification);
  }

  /// Processes generic background notifications, such as email dispatch results.
  void _handleGlobalNotification(List<Object?>? arguments) {
    if (!mounted) return;
    final message = arguments?[0] as String?;
    if (message == null) return;

    if (message == "EMAILS_SENT") {
      AppSnackBar.showSuccess(context, context.l10n.overview_msg_emails_sent);
      ref.invalidate(taskDetailProvider(widget.taskId));
    } else if (message == "EMAILS_FAILED") {
      AppSnackBar.showError(context, context.l10n.overview_msg_emails_failed);
    }
  }

  @override
  void dispose() {
    // Unsubscribe from events and leave the room to clean up resources
    _signalRService.connection?.off("TaskInstancesChanged", method: _handleInstancesChanged);
    _signalRService.leaveTaskRoom(widget.taskId);
    _signalRService.connection?.off("TaskInvitationsChanged", method: _handleInvitationsChanged);
    _signalRService.connection?.off("InvalidEmailsFound", method: _handleInvalidEmails);
    _signalRService.connection?.off("ReceiveNotification", method: _handleGlobalNotification);
    super.dispose();
  }

  /// Submits an update to the task through the API and refreshes local providers.
  void _updateTask(
      BuildContext context,
      TaskDetailModel task, {
        String? title,
        String? notes,
        DateTime? deadline,
        bool? requiresAuth,
        String? allowedDomain,
        TaskState? state,
        bool resetDomain = false,
      }) async {
    final model = TaskUpdateModel(
      id: task.id,
      title: title ?? task.title,
      notes: notes ?? task.notes,
      deadLine: deadline ?? task.deadLine,
      requiresAuthenticationToComplete: requiresAuth ?? task.requiresAuthenticationToComplete,
      allowedDomain: resetDomain ? null : (allowedDomain ?? task.allowedDomain),
      state: state ?? task.state,
      // Crucial: preserve existing emails to avoid accidental deletion by the backend
      invitedEmails: task.invitations.map((e) => e.email).toList(),
    );

    try {
      await ref.read(taskApiServiceProvider).updateTask(task.id, model);
      if (!mounted) return;

      ref.invalidate(taskDetailProvider(widget.taskId));
      ref.invalidate(taskListProvider);
      AppSnackBar.showSuccess(context, context.l10n.overview_msg_task_updated);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, context.l10n.overview_err_update(e.toString()));
    }
  }

  /// Deletes the current task and returns the user to the dashboard.
  Future<void> _deleteTask() async {
    try {
      await ref.read(taskApiServiceProvider).deleteTask(widget.taskId);
      ref.invalidate(taskListProvider);
      if (!mounted) return;

      AppSnackBar.showSuccess(context, context.l10n.overview_msg_task_deleted);
      context.go('/tasks');
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Error: $e");
    }
  }

  /// Displays native date and time pickers to update the task deadline.
  Future<void> _selectDeadline(BuildContext context, TaskDetailModel task) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: task.deadLine.toLocal(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(task.deadLine.toLocal()),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        // Construct the local DateTime and convert to UTC for storage
        final localDeadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _updateTask(context, task, deadline: localDeadline.toUtc());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch relevant providers for full state synchronization
    final asyncTask = ref.watch(taskDetailProvider(widget.taskId));
    final asyncTemplates = ref.watch(taskTemplatesProvider(widget.taskId));
    final asyncInstances = ref.watch(taskInstancesProvider(widget.taskId));
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: asyncTask.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(ref, error),
        data: (task) {
          final taskLink = "${Uri.base.origin}/checkin/p/${task.hash}";
          final bool isCompleted = task.state == TaskState.completed;
          final Color statusBorderColor = isCompleted
              ? Colors.green
              : Theme.of(context).colorScheme.primary;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                vertical: isMobile ? 16 : 30,
                horizontal: isMobile ? 0 : 16
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                    border: isMobile
                        ? Border.symmetric(horizontal: BorderSide(color: statusBorderColor, width: 1.2))
                        : Border.all(color: statusBorderColor, width: 1.2),
                  ),
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Core Information Sections ---
                      EditableTaskTitle(
                        initialTitle: task.title,
                        onSave: (newTitle) => _updateTask(context, task, title: newTitle),
                      ),
                      const SizedBox(height: 16),
                      EditableTaskNotes(
                        initialNotes: task.notes,
                        onSave: (newNotes) => _updateTask(context, task, notes: newNotes),
                      ),
                      const SizedBox(height: 16),

                      // --- Metadata & Actions Header ---
                      TaskOverviewHeader(
                        createdDate: task.createdAt,
                        deadlineDate: task.deadLine,
                        requiresAuth: task.requiresAuthenticationToComplete,
                        lastModified: task.lastModifiedAt,
                        allowedDomain: task.allowedDomain,
                        onDeadlineTap: () => _selectDeadline(context, task),
                        taskId: task.id,
                        currentState: task.state,
                        onStateChanged: (newState) => _updateTask(context, task, state: newState),
                        taskLink: taskLink,
                        onAuthToggle: (bool value) => _updateTask(context, task, requiresAuth: value),
                        onDomainChanged: (String? domain) {
                          _updateTask(
                            context,
                            task,
                            allowedDomain: domain,
                            resetDomain: domain == null,
                          );
                        },
                        onDelete: _deleteTask,
                      ),

                      const SizedBox(height: 16),

                      // --- Invitation Management Widget ---
                      TaskInvitedUsersWidget(
                        task: task,
                      ),

                      // --- Subtask Management & Progress tracking ---
                      asyncTemplates.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => Text(context.l10n.overview_err_load_structure),
                        data: (templates) {
                          // Hide blueprint management if the task has only one primary checkbox
                          final bool isMainTaskOnly =
                              templates.isNotEmpty && templates.every((t) => t.isGeneratedFromTask);

                          return asyncInstances.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => Text(context.l10n.overview_err_load_progress),
                              data: (instances) {
                                return Column(
                                  children: [
                                    if (!isMainTaskOnly) ...[
                                      const SizedBox(height: 24),
                                      SubtaskListSection(
                                        title: context.l10n.overview_checklist_title,
                                        subtasks: templates,
                                        taskId: widget.taskId,
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    SubtaskProgressList(
                                      subtasks: instances,
                                      subtaskMode: task.subtaskMode,
                                      templates: templates,
                                      isMainTaskOnly: isMainTaskOnly,
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a UI state for when task data retrieval fails.
  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.overview_err_load_task),
          Text(error.toString(), style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => ref.invalidate(taskDetailProvider(widget.taskId)),
            child: Text(context.l10n.common_retry),
          ),
        ],
      ),
    );
  }
}