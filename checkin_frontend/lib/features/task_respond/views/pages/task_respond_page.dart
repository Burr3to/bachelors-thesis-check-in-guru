import 'package:checkin_frontend/core/shared_widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/providers/respond_providers.dart';
import '../../../../core/models/action/bulk_subtask_complete_model.dart';
import '../../../../core/models/user/user_profile.dart';
import '../../../../core/utils/app_snack_bar.dart';
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
        AppSnackBar.showSuccess(context, "Task updated successfully");
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

    return Scaffold(
      appBar: AppTopBar(),
      backgroundColor: Colors.white,
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
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
                      const Text("Tasks:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      if (isMainTaskOnly)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text("Please sign below to confirm completion:",
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                        ),
                      RespondentSignatureField(
                        auth: auth,
                        controller: _nameCtrl,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(auth, isMainTaskOnly), // Pridaný parameter
                    ] else ...[
                      _buildAllCompletedBadge(),
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

  Widget _buildSubmitButton(UserProfile? auth, bool isMainTaskOnly) {
    final bool isDisabled = _isLoading || _selectedIds.isEmpty || (auth == null && _nameCtrl.text.isEmpty);

    String buttonText = "Submit (${_selectedIds.length})";
    if (isMainTaskOnly) buttonText = "Sign & Send";
    if (_selectedIds.isEmpty && !isMainTaskOnly) buttonText = "Check tasks you have completed";

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _submit(auth),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAllCompletedBadge() {
    return const Card(
      color: Colors.greenAccent,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up, color: Colors.white),
            SizedBox(width: 8),
            Text("All Tasks are Completed!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}