import 'package:checkin_frontend/core/models/enums/task_enums.dart';
import 'package:checkin_frontend/core/models/subtask_template/subtask_template_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/models/task_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/models/task_list_model.dart';
import 'package:checkin_frontend/features/tasks/data/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:checkin_frontend/features/tasks/views/widgets/task_card.dart';

import '../../../../core/shared_widgets/primary_button.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  // Ponecháme len dátové polia
  List<TaskListModel> _tasks = [];
  bool _isLoading = true;

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


  @override
  void dispose() {
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

          PrimaryButton(
            text: "Create Task",
            icon: Icons.add, // Voliteľné: Ak chceš aj ikonku
            onPressed: () {
              context.go('/home/create');
            },
          ),

          const SizedBox(height: 35),

          //To widget
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                ? const Center(child: Text("Žiadne úlohy"))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5 / 1,
                    ),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];

                      return TaskCard(task: task);
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
