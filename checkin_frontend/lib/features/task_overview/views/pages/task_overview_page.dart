import 'package:checkin_frontend/features/task_overview/views/widgets/main_task_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/quill_viewer.dart';
import '../../../task_list/data/task_providers.dart';
import '../widgets/subtask_list_section.dart';
import '../widgets/subtask_progress_list.dart';
import '../widgets/task_action_buttons.dart';
import '../widgets/task_info_header.dart';

class TaskOverviewPage extends ConsumerWidget {
  final String taskId;

  const TaskOverviewPage({super.key, required this.taskId});

  // Pomocná funkcia na mazanie (zostáva tu, lebo ovláda navigáciu)
  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskApiServiceProvider).deleteTask(taskId);
      ref.invalidate(taskListProvider);
      if (context.mounted) {
        context.go('/app/tasks');
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
    // Sledujeme dáta (Riverpod)
    final asyncTask = ref.watch(taskDetailProvider(taskId));
    final asyncTemplates = ref.watch(taskTemplatesProvider(taskId)); // NOVÝ
    final asyncInstances = ref.watch(taskInstancesProvider(taskId)); // NOVÝ

    return Scaffold(
      backgroundColor: Colors.white,
      body: asyncTask.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(ref, error),
        data: (task) {
          final taskLink = "${Uri.base.origin}/checkin/p/${task.hash}";
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(240, 244, 248, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectionArea(
                        child: Text(
                          task.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (task.notes != null && task.notes!.isNotEmpty) ...[
                        QuillViewer(jsonText: task.notes),
                        const SizedBox(height: 24),
                      ],

                      TaskActionButtons(
                        taskId: taskId,
                        taskLink: taskLink,
                        onDeleteSuccess: () {
                          context.go('/app/tasks');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Task was deleted")),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      TaskInfoHeader(
                        createdDate: task.createdAt,
                        deadlineDate: task.deadLine,
                        requiresAuth: task.requiresAuthenticationToComplete,
                      ),

                      const SizedBox(height: 16),

                      asyncTemplates.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => const Text("Failed to load task structure"),
                        data: (templates) {
                          // Zistíme, či ide o "Hlavný Task" podľa šablón
                          final bool isMainTaskOnly =
                              templates.isNotEmpty &&
                              templates.every((t) => t.isGeneratedFromTask);

                          return asyncInstances.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, s) => const Text("Failed to load progress"),
                            data: (instances) {
                              if (isMainTaskOnly) {
                                // Scenár 1 & 2: Zobrazíme len výsledky podpisov
                                return MainTaskResults(
                                  subtask: templates.first, // Kvôli title/desc
                                  subtaskMode: task.subtaskMode,
                                  allInstances: instances, // Zoznam všetkých podpisov
                                );
                              }

                              // Scenár 3 & 4: Zobrazíme Checklist (Templates) a Progress (Instances)
                              return Column(
                                children: [
                                  SubtaskListSection(
                                    title: "Task Checklist (Definition)",
                                    subtasks: templates,
                                  ),
                                  const SizedBox(height: 24),
                                  const Divider(color: Colors.blueAccent),
                                  const SizedBox(height: 24),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Subtasks Progress (Results)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SubtaskProgressList(subtasks: instances, subtaskMode: task.subtaskMode, templates: templates,),
                                ],
                              );
                            },
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

  // Pomocný widget pre chybu
  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Nepodarilo sa načítať úlohu 😢"),
          Text(error.toString(), style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => ref.invalidate(taskDetailProvider(taskId)),
            child: const Text("Skúsiť znova"),
          ),
        ],
      ),
    );
  }
}
