import 'package:checkin_frontend/core/utils/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';
import 'package:checkin_frontend/core/shared_widgets/primary_button.dart';

import '../../../../core/utils/quill_utils.dart';
import '../../data/models/task_create_model.dart';
import '../../../../core/providers/task_providers.dart';
import '../widgets/subtask_list.dart';
import '../widgets/task_basic_info.dart';
import '../widgets/task_invite_section.dart';
import '../widgets/task_settings_section.dart';
import '../widgets/subtask_input_section.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  final _titleCtrl = TextEditingController();
  final QuillController _quillCtrl = QuillController.basic();
  List<String> _invitedEmails = [];

  DateTime? _selectedDeadline;
  bool _requiresAuth = false;
  SubtaskMode _subtaskMode = SubtaskMode.shared;

  final List<SubtaskTemplateCreateModel> _tempSubtasks = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    super.dispose();
  }

  void _addSubtask(SubtaskTemplateCreateModel subtask) {
    setState(() {
      _tempSubtasks.add(subtask);
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _tempSubtasks.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      // showDatePicker automaticky dedí farby z MaterialApp témy
    );
    if (picked != null) setState(() => _selectedDeadline = picked);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _selectedDeadline == null) {
      AppSnackBar.showInfo(context, "Deadline and Title are required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bool isEditorEmpty = _quillCtrl.document.isEmpty() ||
          _quillCtrl.document.toPlainText().trim().isEmpty;

      final newTask = TaskCreateModel(
          title: _titleCtrl.text,
          notes: !isEditorEmpty ? QuillUtils.controllerToString(_quillCtrl) : null,
          deadLine: _selectedDeadline!.toUtc(),
          subtaskMode: _subtaskMode,
          requiresAuthenticationToComplete: _requiresAuth,
          subtasks: _tempSubtasks,
          invitedEmails: _invitedEmails
      );

      final createdTask = await ref.read(taskApiServiceProvider).createTask(newTask);

      if (mounted) {
        ref.invalidate(taskListProvider);
        context.go('/app/tasks/details/${createdTask.id}');
      }
    } catch (e) {
      if (mounted) {
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e", style: TextStyle(color: cs.onError)),
            backgroundColor: cs.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // Použije surface (biela v Light / čierna v Dark)
      backgroundColor: cs.surface,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 30, bottom: 16, right: 16, left: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // surfaceContainer (tvoja myLightBlueBg v Light / tmavosivá v Dark)
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      "Create New Task",
                      style: TextStyle(
                        fontSize: 18, // Mierne zväčšené
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      )
                  ),
                  const SizedBox(height: 16),

                  // --- Basic Info ---
                  TaskBasicInfo(titleController: _titleCtrl, quillController: _quillCtrl),
                  const SizedBox(height: 8),

                  TaskInviteSection(
                    onEmailsChanged: (emails) {
                      setState(() => _invitedEmails = emails);
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Subtask Input ---
                  SubtaskInputSection(onSubtaskAdded: _addSubtask),
                  const SizedBox(height: 16),

                  // --- Settings ---
                  TaskSettingsSection(
                    selectedDeadline: _selectedDeadline,
                    requiresAuth: _requiresAuth,
                    currentMode: _subtaskMode,
                    onDateTap: _selectDate,
                    onAuthChanged: (newVal) => setState(() => _requiresAuth = newVal),
                    onModeChanged: (newMode) => setState(() => _subtaskMode = newMode),
                  ),
                  const SizedBox(height: 32),

                  // --- Submit Button ---
                  PrimaryButton(
                    text: "Create Task",
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 32),

                  SubtaskList(subtasks: _tempSubtasks, onRemove: _removeSubtask),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}