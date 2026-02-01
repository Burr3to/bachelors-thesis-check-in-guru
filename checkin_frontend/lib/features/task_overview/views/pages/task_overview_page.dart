import 'package:checkin_frontend/core/api/api_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/subtask_instance/subtask_instance_list_model.dart';
import '../../../../core/models/subtask_template/subtask_template_list_model.dart';
import 'package:flutter/services.dart';

import '../../../task_list/data/task_providers.dart';

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
      //backgroundColor: Color.fromRGBO(240, 244, 248, 1),
      backgroundColor: Colors.white,
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
            padding: const EdgeInsets.only(top: 30, bottom: 16, right: 16, left: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),

                // Inside Container
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 244, 248, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),

                  padding: const EdgeInsets.all(24),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: BoxBorder.all(color: Colors.blue.shade300, width: 1)
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _deleteTask(context, ref),
                            label: const Text("Delete",
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.transparent, width: 0)
                            ),
                          ),

                          const SizedBox(width: 18),

                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy, color: Colors.blueAccent),
                            label: const Text("Copy link",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.blueAccent, width: 1)
                            ),
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
                      const Divider(color: Colors.blueAccent,),

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
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(subtasks.title),
                                        subtitle: Text(
                                          subtasks.description ?? "",
                                          style: TextStyle(fontWeight: FontWeight.w100),
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

                      const Divider(color: Colors.blueAccent,),

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
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    subtask.isCompleted
                                        ? Icons.check_circle_outline_rounded
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment:CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (subtask.completedByUserId?.isNotEmpty == true) ...[
                                              const Icon(Icons.verified_user_outlined,
                                                color: Colors.green,
                                                size: 20),
                                              const SizedBox(width: 6,)
                                            ],
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 150),
                                              child: Text(
                                                subtask.respondentName ?? "Unknown",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.green,
                                                ),
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
                                            )
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
