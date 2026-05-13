import 'package:checkin_frontend/core/shared_widgets/app_top_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/providers/respond_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/providers/signalr_provider.dart';

import '../../../../core/models/subtask_instance/bulk_subtask_complete_model.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/shared_widgets/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';
import '../../../../core/models/subtask_instance/subtask_combined_list_model.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/login_required_view.dart';
import '../widgets/respondent_signature_field.dart';
import '../widgets/subtask_list_card.dart';
import '../widgets/task_header.dart';

/// Page allowing users to respond to a task, complete subtasks, and provide a signature.
/// Supports both authenticated and anonymous responses based on task settings.
class TaskRespondPage extends ConsumerStatefulWidget {
  final String taskHash;
  const TaskRespondPage({super.key, required this.taskHash});

  @override
  ConsumerState<TaskRespondPage> createState() => _TaskRespondPageState();
}

class _TaskRespondPageState extends ConsumerState<TaskRespondPage> {
  final _nameCtrl = TextEditingController();
  final Set<String> _selectedIds = {};
  bool _isLoading = false;
  bool _isSubmittedSuccess = false;

  late SignalRService _signalRService;
  String? _joinedTaskIdRoom;

  @override
  void initState() {
    super.initState();
    _signalRService = ref.read(signalRProvider);
  }

  /// Establishes a SignalR connection to a specific task room for real-time updates.
  void _setupSignalRWithData(String taskId) async {
    final roomName = taskId.toLowerCase().trim();
    if (_joinedTaskIdRoom == roomName) return;

    _joinedTaskIdRoom = roomName;

    await _signalRService.joinTaskRoom(roomName);
    _signalRService.connection?.on("TaskInstancesChanged", _handleDataChanged);
    _signalRService.connection?.on("TaskUpdated", _handleDataChanged);
  }

  /// Triggered when external data changes via SignalR.
  /// Invalidates the current provider to refresh the UI.
  void _handleDataChanged(List<Object?>? arguments) {
    if (!mounted) return;
    ref.invalidate(publicTaskProvider(widget.taskHash));
    setState(() {
      if (_selectedIds.isNotEmpty) {
        _selectedIds.clear();
        AppSnackBar.showInfo(context, "Data was updated by another user.");
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _signalRService.connection?.off("TaskInstancesChanged", method: _handleDataChanged);
    _signalRService.connection?.off("TaskUpdated", method: _handleDataChanged);
    if (_joinedTaskIdRoom != null) {
      _signalRService.leaveTaskRoom(_joinedTaskIdRoom!);
    }
    super.dispose();
  }

  /// Submits the selected subtasks and the respondent's name to the backend.
  void _submit(UserProfile? auth) async {
    if (_isLoading) return;

    final String respondentName = auth != null ? auth.name : _nameCtrl.text.trim();
    if (respondentName.isEmpty || _selectedIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final model = BulkSubtaskCompleteModel(
        instanceIds: _selectedIds.toList(),
        respondentName: respondentName,
      );

      await ref.read(subtaskInstanceApiServiceProvider).bulkComplete(model);

      if (mounted) {
        AppSnackBar.showSuccess(context, context.l10n.overview_msg_task_updated);

        // Check if this action completed the entire set of subtasks
        final asyncData = ref.read(publicTaskProvider(widget.taskHash));
        bool isNowEverythingDone = false;
        if (asyncData.hasValue) {
          final List<SubtaskCombinedListModel> subtasks = List.from(asyncData.value!.subtasks);
          final remainingCount = subtasks.where((s) => !s.isCompleted).length;
          if (remainingCount <= _selectedIds.length) isNowEverythingDone = true;
        }

        setState(() {
          _selectedIds.clear();
          if (isNowEverythingDone) _nameCtrl.clear();
          _isSubmittedSuccess = isNowEverythingDone;
        });

        ref.invalidate(publicTaskProvider(widget.taskHash));
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for authentication changes to refresh public data (which might depend on user email/domain)
    ref.listen(authProvider, (previous, next) {
      if (previous?.user?.userId != next.user?.userId) {
        ref.invalidate(publicTaskProvider(widget.taskHash));
      }
    });

    // Automatically setup SignalR when task data becomes available
    ref.listen<AsyncValue>(publicTaskProvider(widget.taskHash), (previous, next) {
      next.whenOrNull(
        data: (data) {
          if (data.id != null) _setupSignalRWithData(data.id!);
        },
      );
    });

    final asyncData = ref.watch(publicTaskProvider(widget.taskHash));
    final auth = ref.watch(authProvider).user;
    final cs = Theme.of(context).colorScheme;

    return asyncData.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => _buildErrorState(ref, e),
      data: (publicTask) {
        // Enforce authentication if the task settings require it
        if (publicTask.requiresAuthenticationToComplete && auth == null) {
          return const Scaffold(appBar: AppTopBar(), body: LoginRequiredView());
        }

        // Domain restriction handling
        if (publicTask.isForbidden) {
          return Scaffold(
            appBar: const AppTopBar(),
            body: _buildForbiddenView(publicTask.forbiddenMessage),
          );
        }

        return Scaffold(
          appBar: const AppTopBar(),
          body: _buildTaskBody(publicTask, auth, cs),
        );
      },
    );
  }

  /// Displays a view indicating the user is not allowed to access the task.
  Widget _buildForbiddenView(String? msg) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.domain_disabled, size: context.isMobile ? 64 : 80, color: Colors.orange),
            SizedBox(height: context.isMobile ? 16 : 24),
            Text("Access Denied", style: TextStyle(fontSize: context.isMobile ? 20 : 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(msg ?? "You do not have permission to access this task.", textAlign: TextAlign.center),
            const SizedBox(height: 32),
            PrimaryButton(
                text: "Logout",
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (mounted) context.push('/login');
                }
            ),
          ],
        ),
      ),
    );
  }

  /// Main body construction for the task response interface.
  Widget _buildTaskBody(dynamic publicTask, UserProfile? auth, ColorScheme cs) {
    final List<SubtaskCombinedListModel> subtasks = List<SubtaskCombinedListModel>.from(
      publicTask.subtasks,
    );

    // Determines if the task is just a signature (one automatic subtask) vs a checklist
    final bool isMainTaskOnly =
        subtasks.isNotEmpty &&
            subtasks.every((SubtaskCombinedListModel s) => s.isGeneratedFromTask);

    // Auto-select the main subtask if it's a signature-only task
    if (isMainTaskOnly && subtasks.isNotEmpty && !subtasks.first.isCompleted && !_isSubmittedSuccess) {
      if (!_selectedIds.contains(subtasks.first.id)) {
        Future.microtask(() {
          if (mounted) setState(() => _selectedIds.add(subtasks.first.id));
        });
      }
    }

    final bool allFinishedInDb = subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted);
    final bool showCompletedBadge = isMainTaskOnly
        ? (allFinishedInDb || _isSubmittedSuccess)
        : allFinishedInDb;

    final bool hasPendingTasks = !showCompletedBadge;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskHeader(
                title: publicTask.title,
                notes: publicTask.notes,
                deadline: publicTask.deadLine,
              ),

              // Checklist view (hidden if it's a simple signature task)
              if (!isMainTaskOnly) ...[
                Text(
                  context.l10n.respond_tasks_label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: context.isMobile ? 8 : 12),
                SubtaskListCard(
                  subtasks: publicTask.subtasks,
                  selectedIds: _selectedIds,
                  onSelectionChanged: (id, isSelected) {
                    setState(() {
                      isSelected ? _selectedIds.add(id) : _selectedIds.remove(id);
                    });
                  },
                ),
                SizedBox(height: context.isMobile ? 16 : 24),
              ],

              const SizedBox(height: 16),
              if (hasPendingTasks) ...[
                if (isMainTaskOnly && auth == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      context.l10n.respond_sign_hint,
                      style: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
                    ),
                  ),
                RespondentSignatureField(
                  auth: auth,
                  controller: _nameCtrl,
                  onChanged: () => setState(() {}),
                  onSubmitted: () => _submit(auth),
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(auth, isMainTaskOnly, cs),
              ] else ...[
                _buildAllCompletedBadge(cs),
              ],
              SizedBox(height: context.isMobile ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the action button for submitting the response.
  Widget _buildSubmitButton(UserProfile? auth, bool isMainTaskOnly, ColorScheme cs) {
    final bool isDisabled =
        _isLoading || _selectedIds.isEmpty || (auth == null && _nameCtrl.text.isEmpty);

    String buttonText = isMainTaskOnly
        ? context.l10n.respond_btn_sign_send
        : context.l10n.respond_btn_submit(_selectedIds.length);

    return SizedBox(
      height: context.isMobile ? 48 : 52,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _submit(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          disabledBackgroundColor: cs.onSurface.withAlpha(30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  /// Displays a success badge when the respondent has no more pending work.
  Widget _buildAllCompletedBadge(ColorScheme cs) {
    return Card(
      color: Colors.green.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              context.l10n.respond_all_completed,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps backend errors to user-friendly views.
  Widget _buildErrorState(WidgetRef ref, Object error) {
    final cs = Theme.of(context).colorScheme;
    final authNotifier = ref.read(authProvider.notifier);

    String title = context.l10n.error_access_denied;
    String message = "An error occurred while loading the task.";
    IconData icon = Icons.error_outline;
    bool showLogoutButton = false;
    bool showLoginButton = false;

    if (error is DioException) {
      final response = error.response;
      final statusCode = response?.statusCode;

      String? serverMessage;
      if (response?.data != null && response?.data is Map) {
        serverMessage = response?.data['message'];
      }

      if (statusCode == 403) {
        title = "Access Denied";
        message = serverMessage ?? context.l10n.error_not_on_list_msg;
        icon = Icons.domain_disabled;
        showLogoutButton = true;
      }
      else if (statusCode == 401) {
        title = context.l10n.error_private_task;
        message = context.l10n.error_private_task_msg;
        icon = Icons.lock_person_outlined;
        showLoginButton = true;
      }
      else if (statusCode == 404) {
        title = context.l10n.error_not_found;
        message = context.l10n.error_not_found_msg;
        icon = Icons.search_off;
      }
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: context.isMobile ? 64 : 80, color: cs.primary),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: context.isMobile ? 20 : 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (showLogoutButton) ...[
              PrimaryButton(
                  text: "Login with another account",
                  onPressed: () async {
                    await authNotifier.signOut();
                    if (mounted) context.push('/login');
                  }
              ),
              const SizedBox(height: 12),
            ],
            if (showLoginButton)
              PrimaryButton(text: context.l10n.auth_askforlogin, onPressed: () => context.push('/login'))
            else
              OutlinedButton(onPressed: () => context.go('/'), child: Text(context.l10n.common_back_to_home)),
          ],
        ),
      ),
    );
  }
}