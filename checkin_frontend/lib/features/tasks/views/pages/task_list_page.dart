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
  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final meno = user?.name ?? 'hosť';

    // 1. Sledujeme providera (dáta sa sťahujú samé)
    final asyncTasks = ref.watch(taskListProvider);

    return Scaffold(
      body: Padding(
        // Pridal som Padding, nech to nie je nalepené na krajoch
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vitajte $meno", style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 35),

            PrimaryButton(
              text: "Create Task",
              icon: Icons.add,
              onPressed: () {
                context.go('/home/create');
              },
            ),

            const SizedBox(height: 35),

            // 2. TOTO JE TÁ ZMENA:
            Expanded(
              // .when() sa postará o Loading, Error aj Data
              child: asyncTasks.when(
                // A) Načítavanie
                loading: () => const Center(child: CircularProgressIndicator()),

                // B) Chyba
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chyba: $error", style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(taskListProvider), // Skúsiť znova
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                ),

                // C) Dáta sú tu!
                data: (queryResult) {
                  final tasks = queryResult.items; // Vytiahneme zoznam z QueryResultu

                  if (tasks.isEmpty) {
                    return const Center(child: Text("Žiadne úlohy"));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5 / 1,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(task: task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button na refresh (voliteľné, lebo pull-to-refresh je lepší, ale zatiaľ OK)
      floatingActionButton: FloatingActionButton(
        heroTag: "btnRefresh",
        onPressed: () {
          // Takto sa robí refresh s Riverpodom:
          ref.invalidate(taskListProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
