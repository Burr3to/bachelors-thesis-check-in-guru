import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importuj tvoje modely a widgety
import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';
import 'package:checkin_frontend/core/shared_widgets/primary_button.dart';

import '../../../task_list/data/models/task_create_model.dart';
import '../../../task_list/data/task_providers.dart';
import '../widgets/subtask_list.dart';
import '../widgets/task_basic_info.dart';
import '../widgets/task_settings_section.dart';
import '../widgets/subtask_input_section.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  // Stav formulára
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _selectedDeadline;
  bool _requiresAuth = false;
  SubtaskMode _subtaskMode = SubtaskMode.shared;

  final List<SubtaskTemplateCreateModel> _tempSubtasks = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // --- LOGIKA ---

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
    );
    if (picked != null) setState(() => _selectedDeadline = picked);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Title and Deadline are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newTask = TaskCreateModel(
        title: _titleCtrl.text,
        notes: _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
        deadLine: _selectedDeadline!.toUtc(),
        subtaskMode: _subtaskMode,
        requiresAuthenticationToComplete: _requiresAuth,
        subtasks: _tempSubtasks,
      );

      // 1. Získame vytvorený task z API
      final createdTask = await ref.read(taskApiServiceProvider).createTask(newTask);

      if (mounted) {
        ref.invalidate(taskListProvider);
        context.go('/app/tasks/details/${createdTask.id}');
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.topCenter, // Zarovnaj na vrch a stred
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 30, bottom: 16, right: 16, left: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 244, 248, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Create New Task", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  // --- Basic Info ---
                  TaskBasicInfo(titleController: _titleCtrl, descController: _descCtrl),
                  const SizedBox(height: 8),

                  // --- Subtask Input ---
                  SubtaskInputSection(onSubtaskAdded: _addSubtask),
                  const SizedBox(height: 16),

                  // --- Settings ---
                  TaskSettingsSection(
                    selectedDeadline: _selectedDeadline,
                    requiresAuth: _requiresAuth,
                    currentMode: _subtaskMode, // Mód ide sem
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
