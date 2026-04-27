import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/shared_widgets/primary_button.dart';
import '../../../../core/providers/task_providers.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filters_drawer.dart';
import '../widgets/task_list_header.dart';
import '../widgets/task_pagination_bar.dart';

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
    final asyncTasks = ref.watch(taskListProvider);
    final pagination = ref.watch(taskQueryProvider);


    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }


    return Scaffold(
      // 2. ZMENA: Namiesto Colors.white
      backgroundColor: colorScheme.surface,
      endDrawer: const TaskFiltersDrawer(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            const TaskListHeader(),

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
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  // Použijeme Column, aby sme pod GridView pridali PaginationBar
                  return Stack(
                    children: [
                      // 1. VRSTVA: Zoznam úloh
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20), // Miesto pre pohodlný scroll
                        child: GridView.builder(
                          // Pridáme extra padding dole priamo do GridView,
                          // aby posledný riadok úloh nekončil presne pod lištou
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 700,
                            mainAxisExtent: 290,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(task: task);
                          },
                        ),
                      ),

                      // 2. VRSTVA: Plávajúca paginácia (zarovnaná na stred dole)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: TaskPaginationBar(totalCount: queryResult.totalCount),
                      ),
                    ],
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
