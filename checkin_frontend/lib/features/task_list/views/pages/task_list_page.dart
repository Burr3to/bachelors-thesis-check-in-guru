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
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final meno = user?.name ?? 'hosť';

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 1. Sledujeme providera (dáta sa sťahujú samé)
    final asyncTasks = ref.watch(taskListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        // Pridal som Padding, nech to nie je nalepené na krajoch
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

            // 2. TOTO JE TÁ ZMENA:
            Expanded(
              // .when() sa postará o Loading, Error aj Data
              child: asyncTasks.when(
                // A) Načítavanie
                loading: () => const Center(child: CircularProgressIndicator()),

                // B) Chyba
                error: (error, stack) {
                  print("Detail chyby: $error"); // Pozri si toto v konzole prehliadača (F12)
                  print("Stacktrace: $stack");
                  return Center(child: Text("Chyba: $error"));
                },
                // C) Dáta sú tu!
                data: (queryResult) {
                  final tasks = queryResult.items; // Vytiahneme zoznam z QueryResultu

                  if (tasks.isEmpty) {
                    return const Center(child: Text("Žiadne úlohy"));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 900,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 4 / 1,
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
