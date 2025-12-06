import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_detail_provider.dart';
// Importuj model task_detail_model.dart ak treba

class TaskOverviewPage extends ConsumerWidget {
  final String taskId;

  const TaskOverviewPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Sledujeme providera s konkrétnym ID
    // Riverpod automaticky vie: "Aha, chceš task 123? Pozriem sa či ho mám, ak nie, stiahnem ho."
    final asyncTask = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: const Text("Detail úlohy")),
      // 2. .when() rieši 3 stavy: Data, Error, Loading
      body: asyncTask.when(
        // A. Načítavanie
        loading: () => const Center(child: CircularProgressIndicator()),

        // B. Chyba
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Nepodarilo sa načítať úlohu 😢"),
              Text(error.toString(), style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Refresh (invalidate) prinúti providera stiahnuť dáta znova
                  ref.invalidate(taskDetailProvider(taskId));
                },
                child: const Text("Skúsiť znova"),
              ),
            ],
          ),
        ),

        // C. Dáta sú tu! (task je typu TaskDetailModel)
        data: (task) {
          final createdDate = DateFormat(
            'dd.MM.yyyy HH:mm',
          ).format(task.createdAt.toLocal());
          final deadlineDate = DateFormat(
            'dd.MM.yyyy HH:mm',
          ).format(task.deadLine.toLocal());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Horny sedy container
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(236, 236, 240, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Created On",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(createdDate),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Deadline", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(deadlineDate),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last Modified",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

                          Text("TODO"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Identity Verification",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

                          Text("TODO"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(task.title, style: Theme.of(context).textTheme.headlineMedium),

                const SizedBox(height: 24),

                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  Text(task.notes!),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
