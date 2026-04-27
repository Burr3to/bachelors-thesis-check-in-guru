import 'package:checkin_frontend/core/shared_widgets/app_top_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/providers/respond_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/action/bulk_subtask_complete_model.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../auth/views/providers/auth_provider.dart';
import '../widgets/login_required_view.dart';
import '../widgets/respondent_signature_field.dart';
import '../widgets/subtask_list_card.dart';
import '../widgets/task_header.dart';


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

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit(UserProfile? auth) async {
    final String respondentName = auth != null ? auth.name : _nameCtrl.text;
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
        ref.invalidate(publicTaskProvider(widget.taskHash));
        setState(() {
          _selectedIds.clear();
          _nameCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(publicTaskProvider(widget.taskHash));
    final auth = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppTopBar(),
      backgroundColor: cs.surface,
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) {
          // PRIDAJ TENTO PRINT PRE DEBUG:
          print("FLUTTER ERROR CAUGHT: $e");
          return _buildErrorState(ref, e);
        },
        data: (publicTask) {
          if (publicTask.requiresAuthenticationToComplete && auth == null) {
            return const LoginRequiredView();
          }

          final bool isMainTaskOnly = publicTask.subtasks.isNotEmpty &&
              publicTask.subtasks.every((s) => s.isGeneratedFromTask);

          // Ak je to hlavný task a ešte nie je vybraný v set-e, pridáme ho tam automaticky
          if (isMainTaskOnly && !publicTask.subtasks.first.isCompleted) {
            if (!_selectedIds.contains(publicTask.subtasks.first.id)) {
              Future.microtask(() => setState(() {
                _selectedIds.add(publicTask.subtasks.first.id);
              }));
            }
          }

          final hasPendingTasks = publicTask.subtasks.any((s) => !s.isCompleted);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TaskHeader(
                      title: publicTask.title,
                      notes: publicTask.notes,
                      deadline: publicTask.deadLine,
                    ),

                    if (!isMainTaskOnly) ...[
                      Text(context.l10n.respond_tasks_label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface)),
                      const SizedBox(height: 8),
                      SubtaskListCard(
                        subtasks: publicTask.subtasks,
                        selectedIds: _selectedIds,
                        onSelectionChanged: (id, isSelected) {
                          setState(() {
                            isSelected ? _selectedIds.add(id) : _selectedIds.remove(id);
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],


                    const SizedBox(height: 24),
                    if (hasPendingTasks) ...[
                      // Ak je to main task only, môžeme tu pridať malý text "Please sign to complete this task"
                      if (isMainTaskOnly && auth == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(context.l10n.respond_sign_hint,
                              style: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
                        ),
                      RespondentSignatureField(
                        auth: auth,
                        controller: _nameCtrl,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(auth, isMainTaskOnly, cs), // Pridaný parameter
                    ] else ...[
                      _buildAllCompletedBadge(cs),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(UserProfile? auth, bool isMainTaskOnly, ColorScheme cs) {
    final bool isDisabled = _isLoading || _selectedIds.isEmpty || (auth == null && _nameCtrl.text.isEmpty);
    String buttonText = isMainTaskOnly ? context.l10n.respond_btn_sign_send : context.l10n.respond_btn_submit(_selectedIds.length);

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _submit(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600], // Zelená je dobrá pre submit
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


  Widget _buildAllCompletedBadge(ColorScheme cs) {
    return Card(
      color: Colors.green.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(context.l10n.respond_all_completed, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String title = context.l10n.error_access_denied;
    String message = "Došlo k chybe pri načítaní úlohy.";
    IconData icon = Icons.error_outline;
    bool showLoginButton = false;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      // Tu spracujeme ten 403, čo vidíš v Network tabe
      if (statusCode == 403) {
        title = context.l10n.error_not_on_list;
        message = context.l10n.error_not_on_list_msg;
        icon = Icons.person_off_outlined;
      } else if (statusCode == 401) {
        title = context.l10n.error_private_task;
        message = context.l10n.error_private_task_msg;
        icon = Icons.lock_person_outlined;
        showLoginButton = true;
      } else if (statusCode == 404) {
        title = context.l10n.error_not_found;
        message = context.l10n.error_not_found_msg;
        icon = Icons.search_off;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: cs.primary),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 32),
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