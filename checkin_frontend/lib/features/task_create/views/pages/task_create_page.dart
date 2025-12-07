import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importuj tvoje modely a widgety
import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/models/task_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/task_providers.dart';
import 'package:checkin_frontend/core/shared_widgets/primary_button.dart';

import '../widgets/subtask_list.dart';
import '../widgets/task_basic_info.dart';
import '../widgets/task_settings_section.dart';
import '../widgets/subtask_input_section.dart';
// import '../widgets/subtask_list.dart'; (Tento si spravíš sám podľa vzoru ListView z minula)

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

      await ref.read(taskApiServiceProvider).createTask(newTask);

      if (mounted) {
        context.pop(); // Vráti sa na home
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Task")),
      body: Align(
        alignment: Alignment.topCenter, // Zarovnaj na vrch a stred
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Basic Info ---
                TaskBasicInfo(titleController: _titleCtrl, descController: _descCtrl),
                const SizedBox(height: 24),

                // --- Subtask Input ---
                SubtaskInputSection(
                  onSubtaskAdded: _addSubtask,
                  currentMode: _subtaskMode,
                  onModeChanged: (newSet) => setState(() => _subtaskMode = newSet.first),
                ),
                const SizedBox(height: 16),

                // --- Settings ---
                TaskSettingsSection(
                  selectedDeadline: _selectedDeadline,
                  requiresAuth: _requiresAuth,
                  onDateTap: _selectDate,
                  onAuthToggle: () => setState(() => _requiresAuth = !_requiresAuth),
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
    );
  }
}
