import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';

// --- TENTO IMPORT PRIDAJ ---
import '../../../../core/utils/responsive.dart';

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
    await _signalRService.joinUserRoom(user.userId);
    _signalRService.connection?.on("AuthorTaskUpdated", _handleAuthorTaskUpdated);
  }

  void _handleAuthorTaskUpdated(List<Object?>? arguments) {
    final updatedTaskId = arguments?[0] as String?;
    print("DEBUG: SignalR - PRIJATÝ SIGNÁL! Zmenil sa task: $updatedTaskId");

    if (mounted) {
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

    // Zistíme, či sme na mobile
    final isMobile = context.isMobile;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawer: const TaskFiltersDrawer(),

      // ZMENA PRE MOBIL: Pridáme Floating Action Button (len na mobile)
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () => context.go('/tasks/create'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      )
          : null,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children:[
            // HLAVIČKA
            const TaskListHeader(),

            // ZOZNAM ÚLOH
            Expanded(
              child: asyncTasks.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  return Center(
                    child: Text(
                      context.l10n.tasks_error(error.toString()),
                      style: TextStyle(color: colorScheme.error),
                    ),
                  );
                },
                data: (queryResult) {
                  final tasks = queryResult.items;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.tasks_empty,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  return Stack(
                    children:[
                      // 1. VRSTVA: Zoznam úloh
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        // ZMENA PRE MOBIL: GridView pre Desktop, ListView pre Mobil
                        child: isMobile
                            ? ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return TaskCard(task: tasks[index]);
                          },
                        )
                            : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 700,
                            mainAxisExtent: 260,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return TaskCard(task: tasks[index]);
                          },
                        ),
                      ),

                      // 2. VRSTVA: Plávajúca paginácia
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