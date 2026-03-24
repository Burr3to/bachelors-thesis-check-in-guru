import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/providers/task_providers.dart';
import '../widgets/task_card.dart';

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
  Widget build(BuildContext context) {
    // 1. SEM DAJ TENTO RIADOK
    final colorScheme = Theme.of(context).colorScheme;

    final user = ref.watch(authProvider).user;
    // final meno = user?.name ?? 'hosť'; // Ak nepotrebuješ, môžeš zmazať

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final asyncTasks = ref.watch(taskListProvider);

    return Scaffold(
      // 2. ZMENA: Namiesto Colors.white
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PrimaryButton(
              text: "Create Task",
              icon: Icons.add,
              onPressed: () {
                context.go('/app/create');
              },
            ),
            const SizedBox(height: 35),
            Expanded(
              child: asyncTasks.when(
                loading: () => const Center(child: CircularProgressIndicator()),

                // 3. ZMENA: Farba chyby
                error: (error, stack) {
                  return Center(
                    child: Text(
                      "Chyba: $error",
                      style: TextStyle(color: colorScheme.error), // Použije červenú z témy
                    ),
                  );
                },

                // 4. ZMENA: Farba pre prázdny stav
                data: (queryResult) {
                  final tasks = queryResult.items;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        "Žiadne úlohy",
                        style: TextStyle(color: colorScheme.onSurfaceVariant), // Jemná šedá/biela
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 900,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 180,
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
    );
  }
}
