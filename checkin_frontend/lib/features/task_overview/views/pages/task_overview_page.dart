import 'package:checkin_frontend/core/api/api_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/subtask_instance/subtask_instance_list_model.dart';
import '../../../../core/models/subtask_template/subtask_template_list_model.dart';
import 'package:flutter/services.dart';

import '../../../task_list/data/task_providers.dart'; // <--- TOTO JE KĽÚČOVÉ
// Importuj model task_detail_model.dart ak treba

class TaskOverviewPage extends ConsumerWidget {
  final String taskId;

  const TaskOverviewPage({super.key, required this.taskId});

  Future<void> _deleteTask(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskApiServiceProvider).deleteTask(taskId);

      ref.invalidate(taskListProvider);

      if (context.mounted) {
        context.go('/home');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Task was deleted")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTask = ref.watch(taskDetailProvider(taskId));
    final asyncSubtasks = ref.watch(taskSubtasksProvider(taskId));

    return Scaffold(
      appBar: AppBar(title: const Text("Go back"), backgroundColor: Colors.white),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
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

          final String baseUrl = Uri.base.origin;
          final String taskLink = "$baseUrl/checkin/${task.hash}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),

                  padding: const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
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
                                Text(
                                  "Deadline",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
                                task.requiresAuthenticationToComplete
                                    ? Text(
                                        "Enabled",
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : Text(
                                        "Disabled",
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _deleteTask(context, ref),
                            label: const Text("Delete"),
                            icon: const Icon(Icons.delete),
                          ),

                          const SizedBox(width: 18),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy),
                            label: const Text("Copy link"),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: taskLink));

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied to clipboard"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text(task.title, style: Theme.of(context).textTheme.headlineMedium),

                      const SizedBox(height: 24),
                      if (task.notes != null && task.notes!.isNotEmpty) ...[
                        Text(task.notes!),
                        const SizedBox(height: 24),
                      ],
                      const Divider(),

                      Container(
                        decoration: BoxDecoration(),
                        padding: EdgeInsets.only(bottom: 8, top: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Task Checklist",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            asyncSubtasks.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => const Text("Failed to load Substask"),
                              data: (subtasks) {
                                if (subtasks.isEmpty) return Text("No Subtatks");

                                return Column(
                                  children: subtasks.map((subtasks) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(subtasks.title),
                                        subtitle: Text(
                                          subtasks.description ?? "",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.only(left: 18),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      const SizedBox(height: 24),
                      const Text(
                        "Subtasks Progress",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      asyncSubtasks.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => const Text("Failed to load subtasks"),
                        data: (subtasks) {
                          if (subtasks.isEmpty) return const Text("No subtasks.");

                          return Column(
                            children: subtasks.map((subtask) {
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    subtask.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: subtask.isCompleted
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  title: Text(subtask.title),
                                  subtitle: subtask.description != null
                                      ? Text(subtask.description!)
                                      : null,
                                  trailing: subtask.isCompleted
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Vycentruj zvislo
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end, // Zarovnaj doprava
                                          mainAxisSize: MainAxisSize
                                              .min, // KĽÚČOVÉ: Neber všetko miesto
                                          children: [
                                            Text(
                                              subtask.respondentName ?? "Unknown",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            Text(
                                              DateFormat(
                                                'dd.MM HH:mm',
                                              ).format(subtask.completedAt!.toLocal()),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubtaskList(
    List<SubtaskTemplateListModel> templates,
    List<SubtaskInstanceListModel> instances,
  ) {
    if (templates.isEmpty) return const Text("No subtasks defined.");

    return Column(
      children: templates.map((template) {
        // Nájdi všetky inštancie, ktoré patria k tejto šablóne
        final relatedInstances = instances
            .where((i) => i.templateSubtaskId == template.id)
            .toList();

        // Zisti, či je to splnené (napr. ak existuje aspoň jedna completed inštancia)
        final isCompleted = relatedInstances.any((i) => i.isCompleted);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            title: Text(
              template.title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: template.description != null ? Text(template.description!) : null,
            children: [
              // Tu vypíšeme, kto to splnil (z inštancií)
              if (relatedInstances.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Zatiaľ nikto nereagoval."),
                )
              else
                ...relatedInstances.map(
                  (inst) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.person, size: 16),
                    title: Text(
                      inst.assignedToUserId ?? "Shared User",
                    ), // Tu by si potreboval meno
                    trailing: inst.isCompleted
                        ? Text(
                            DateFormat('dd.MM HH:mm').format(inst.completedAt!.toLocal()),
                          )
                        : const Text("Pending", style: TextStyle(color: Colors.orange)),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
