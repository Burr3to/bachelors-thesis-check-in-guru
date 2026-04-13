import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/providers/task_providers.dart';
import '../widgets/task_card.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});


  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late SignalRService _signalRService;

  @override
  void dispose() {
    _signalRService.connection?.off("AuthorTaskUpdated", method: _handleAuthorTaskUpdated);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _signalRService = ref.read(signalRProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });
  }

  void _setupSignalR() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      print("DEBUG: SignalR - User je null, nemôžem sa pripojiť do UserRoom");
      return;
    }

    print("DEBUG: SignalR - Pripájam sa do UserRoom pre: ${user.userId}");

    // 1. Vstúpime do miestnosti pre autora
    await _signalRService.joinUserRoom(user.userId);

    // 2. Začneme počúvať na event "AuthorTaskUpdated"
    _signalRService.connection?.on("AuthorTaskUpdated", _handleAuthorTaskUpdated);
  }

  void _handleAuthorTaskUpdated(List<Object?>? arguments) {
    final updatedTaskId = arguments?[0] as String?;
    print("DEBUG: SignalR - PRIJATÝ SIGNÁL! Zmenil sa task: $updatedTaskId");

    if (mounted) {
      // Obnovíme zoznam úloh
      ref.invalidate(taskListProvider);
      print("DEBUG: SignalR - Provider taskListProvider bol invalidovaný");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final user = ref.watch(authProvider).user;

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
