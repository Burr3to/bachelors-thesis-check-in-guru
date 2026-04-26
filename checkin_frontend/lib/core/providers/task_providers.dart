import 'package:checkin_frontend/core/models/Statistics/task_summary_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/task_list/data/models/query/task_list_query.dart';
import '../../features/task_overview/data/models/subtask_combined_list_model.dart';
import '../../features/task_overview/data/models/task_detail_model.dart';
import '../../features/task_list/data/models/query/query_result.dart';
import '../../features/task_list/data/models/task_list_model.dart';
import '../models/enums/task_enums.dart';
import '../services/subtask_instance_api_service.dart';
import '../services/subtask_template_api_service.dart';
import '../services/task_api_service.dart';

// --- PAGINÁCIA (STAV A NOTIFIER) ---

class TaskPagination {
  final int page;
  final int pageSize;
  TaskPagination({required this.page, required this.pageSize});

  TaskPagination copyWith({int? page, int? pageSize}) {
    return TaskPagination(page: page ?? this.page, pageSize: pageSize ?? this.pageSize);
  }
}

class TaskQueryNotifier extends StateNotifier<TaskListQuery> {
  TaskQueryNotifier() : super(const TaskListQuery());

  void updateSearch(String? text) {
    // Pri hľadaní sa vždy vraciame na stranu 1
    state = state.copyWith(nameContains: text, pageNumber: 1);
  }

  void setPage(int page) => state = state.copyWith(pageNumber: page);

  void setStatus(TaskState? status) => state = state.copyWith(status: status, pageNumber: 1);

  void setMode(SubtaskMode? mode) => state = state.copyWith(mode: mode, pageNumber: 1);

  void setVisibility(bool? requiresAuth) =>
      state = state.copyWith(requiresAuth: requiresAuth, pageNumber: 1);

  void setOverdue(bool onlyOverdue) =>
      state = state.copyWith(onlyOverdue: onlyOverdue, pageNumber: 1);

  void setSort(String field, bool desc) =>
      state = state.copyWith(sortBy: field, sortDesc: desc, pageNumber: 1);

  void setOnlyActive(bool val) {
    state = state.copyWith(
      onlyActive: val,
      onlyOverdue: val ? false : state.onlyOverdue,
      pageNumber: 1,
    );
  }

  void reset() => state = const TaskListQuery();
}

final taskQueryProvider = StateNotifierProvider<TaskQueryNotifier, TaskListQuery>((ref) {
  return TaskQueryNotifier();
});

// Provider pre stav paginácie
final taskListProvider = FutureProvider.autoDispose<QueryResult<TaskListModel>>((ref) async {
  final api = ref.watch(taskApiServiceProvider);
  final query = ref.watch(taskQueryProvider);

  return api.getTasks(
    pageNumber: query.pageNumber,
    pageSize: query.pageSize,
    sortBy: query.sortBy,
    sortDesc: query.sortDesc,
    nameContains: query.nameContains,
    mode: query.mode != null
        ? query.mode!.index + 1
        : null, // ! For a fix change enum in BE .Common, will break database
    status: query.status?.index,
    requiresAuth: query.requiresAuth,
    onlyOverdue: query.onlyOverdue,
      onlyActive: query.onlyActive
  );
});

// --- API SERVICE PROVIDERY ---

final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskApiService(dio);
});

final subtaskTemplateApiServiceProvider = Provider<SubtaskTemplateApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return SubtaskTemplateApiService(dio);
});

final subtaskInstanceApiServiceProvider = Provider<SubtaskInstanceApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return SubtaskInstanceApiService(dio);
});

// --- DATA PROVIDERY ---

final taskDetailProvider = FutureProvider.autoDispose.family<TaskDetailModel, String>((
  ref,
  taskId,
) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTask(taskId);
});

final taskTemplatesProvider = FutureProvider.autoDispose
    .family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
      final apiService = ref.watch(taskApiServiceProvider);
      return apiService.getTemplates(taskId);
    });

final taskInstancesProvider = FutureProvider.autoDispose
    .family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
      final apiService = ref.watch(taskApiServiceProvider);
      return apiService.getInstances(taskId);
    });

// --- ŠTATISTIKY ---

final allTaskStatsProvider = FutureProvider<Map<String, TaskSummaryStats>>((ref) async {
  // Počkáme na načítanie aktuálneho zoznamu úloh
  final tasksResult = await ref.watch(taskListProvider.future);
  final ids = tasksResult.items.map((t) => t.id).toList();

  if (ids.isEmpty) return {};

  final api = ref.watch(taskApiServiceProvider);
  final statsList = await api.getTaskSummaryStats(ids);

  return {for (var s in statsList) s.taskId: s};
});
