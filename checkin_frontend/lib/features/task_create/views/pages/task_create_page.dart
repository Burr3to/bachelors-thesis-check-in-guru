import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importuj tvoje modely a widgety
import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/models/task_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/task_providers.dart';
import 'package:checkin_frontend/core/shared_widgets/primary_button.dart';

import '../../../task_overview/data/models/task_detail_model.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Deadline are required")));
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
        // 2. Namiesto odchodu zobrazíme Dialog s linkom
        await _showSuccessDialog(createdTask);
      }
    } catch (e) {
      print(e);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog(TaskDetailModel task) async {
    // Vygenerujeme link.
    // V reále: base url zoberieš z nastavení, alebo použiješ window.location ak je to web
    // Pre lokálny vývoj:
    final String link = "http://localhost:5000/checkin/${task.hash}";

    await showDialog(
      context: context,
      barrierDismissible: false, // User musí kliknúť na tlačidlo, nemôže kliknúť vedľa
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text("Task Created!"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your task is ready. Share this link with others:"),
              const SizedBox(height: 16),

              // Pekný box s linkom
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        link,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // Kopírovanie do schránky
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Link copied to clipboard!")),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Tlačidlo, ktoré nás konečne vráti na Home
            TextButton(
              onPressed: () {
                context.pop(); // Zavrie dialog
                context.pop(); // Zavrie TaskCreatePage (vráti na Home)
                // Alebo bezpečnejšie: context.go('/home');
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
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
