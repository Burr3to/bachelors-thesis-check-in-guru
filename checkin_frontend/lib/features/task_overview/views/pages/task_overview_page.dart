import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_detail_provider.dart';
// Importuj model task_detail_model.dart ak treba

class TaskOverviewPage extends ConsumerWidget {
  final String taskId;

  const TaskOverviewPage({
    super.key,
    required this.taskId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Sledujeme providera s konkrétnym ID
    // Riverpod automaticky vie: "Aha, chceš task 123? Pozriem sa či ho mám, ak nie, stiahnem ho."
    final asyncTask = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail úlohy"),
      ),
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
                  child: const Text("Skúsiť znova")
              )
            ],
          ),
        ),

        // C. Dáta sú tu! (task je typu TaskDetailModel)
        data: (task) {
          final createdDate = DateFormat('dd.MM.yyyy HH:mm').format(task.createdAt.toLocal());
          final deadlineDate = DateFormat('dd.MM.yyyy HH:mm').format(task.deadLine.toLocal());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nadpis
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                // Hash (napr. kód úlohy)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text("#${task.hash}", style: const TextStyle(fontFamily: 'monospace')),
                ),

                const SizedBox(height: 24),

                // Karta s informáciami
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_today, "Vytvorené", createdDate),
                        const Divider(),
                        _buildInfoRow(Icons.timer, "Deadline", deadlineDate, isRed: true),
                        const Divider(),
                        _buildInfoRow(Icons.person, "Vytvoril", "ID: ${task.createdById}"), // Tu by sme chceli meno, ale zatiaľ máme ID
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Poznámky (ak sú)
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  Text("Poznámky:", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(task.notes!),
                  const SizedBox(height: 24),
                ],

              ],
            ),
          );
        },
      ),
    );
  }

  // Pomocná metóda pre riadky v tabuľke
  Widget _buildInfoRow(IconData icon, String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: TextStyle(color: isRed ? Colors.red : null)),
        ],
      ),
    );
  }
}