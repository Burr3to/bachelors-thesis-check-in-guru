import 'package:checkin_frontend/features/tasks/data/models/task_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/models/task_list_model.dart';
import 'package:checkin_frontend/features/tasks/data/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  // Ponecháme len dátové polia
  List<TaskListModel> _tasks = [];
  bool _isLoading = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    // Načítanie dát pri štarte
    _loadData();
  }

  // Metóda pre volanie GET /api/Task
  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final result = await ref.read(taskApiServiceProvider).getTasks();

      if (!mounted) return;
      setState(() {
        _tasks = result.items.toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Chyba pri načítaní úloh: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createTask() async {
    if (_titleController.text.isEmpty) {
      print("Title is required!");
      return;
    }

    try {
      final TaskCreateModel newTaskModel = TaskCreateModel(
        title: _titleController.text,
        deadLine: _selectedDeadline!.toUtc(),
        notes: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );
      final result = await ref.read(taskApiServiceProvider).createTask(newTaskModel);

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDeadline = null;
      });

      await _loadData();
      print("Task created successfully!");
    } catch (e) {
      print("Error for createTask");
    }
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
    return picked;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final meno = user?.name ?? 'hosť';

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vitajte $meno", style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: 35),

          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Title",
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Deadline",
                        ),
                        child: Text(
                          _selectedDeadline == null
                              ? "Choose date"
                              : DateFormat('dd.MM.yyyy').format(_selectedDeadline!),
                          style: TextStyle(
                            color: _selectedDeadline == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _createTask, child: const Text("Add Task")),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                ? const Center(child: Text("Žiadne úlohy"))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];

                      final deadLine = DateFormat(
                        'dd.MM.yyyy HH:mm',
                      ).format(task.deadLine.toLocal());

                      final dateString = DateFormat(
                        'dd.MM.yyyy HH:mm',
                      ).format(task.createdAt.toLocal());

                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(task.title),
                              const SizedBox(height: 8),
                              Text(dateString),
                              Text(deadLine),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btnRefresh",
        onPressed: _loadData, // Ponecháme len refresh
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
