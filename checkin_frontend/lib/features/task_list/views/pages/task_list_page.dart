import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';

import '../../../../core/providers/signalr_provider.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/task_card.dart';
import '../widgets/task_filters_drawer.dart';
import '../widgets/task_list_header.dart';
import '../widgets/task_pagination_bar.dart';

/// Main dashboard page displaying a paginated list of tasks created by the user.
/// Includes real-time updates via SignalR to refresh the list when tasks change.
class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = ref.read(signalRProvider);

    // Defer SignalR setup until after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSignalR();
    });
  }

  /// Sets up the SignalR connection and joins the user-specific room.
  void _setupSignalR() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    // Join the private user room for dashboard-wide updates
    await _signalRService.joinUserRoom(user.userId);
    _signalRService.connection?.on("AuthorTaskUpdated", _handleAuthorTaskUpdated);
  }

  /// Callback triggered when the server notifies that a task owned by the user has changed.
  void _handleAuthorTaskUpdated(List<Object?>? arguments) {
    if (mounted) {
      // Invalidate the provider to trigger a fresh data fetch from the API
      ref.invalidate(taskListProvider);
    }
  }

  @override
  void dispose() {
    // Unsubscribe from real-time events to prevent memory leaks
    _signalRService.connection?.off("AuthorTaskUpdated", method: _handleAuthorTaskUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).user;
    final asyncTasks = ref.watch(taskListProvider);
    final isMobile = context.isMobile;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawer: const TaskFiltersDrawer(),

      // Display FAB only on mobile for easier task creation
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
          children: [
            // Header with search, filtering, and view controls
            const TaskListHeader(),

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
                    children: [
                      // Layer 1: The Task Collection View
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: isMobile
                        // Single column list for mobile screens
                            ? ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return TaskCard(task: tasks[index]);
                          },
                        )
                        // Multi-column grid for desktop/web screens
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

                      // Layer 2: Floating Pagination Controls
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