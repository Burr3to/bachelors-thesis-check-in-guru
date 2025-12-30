import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart'; // Import dioProvider
import '../../task_overview/data/models/subtask_combined_list_model.dart';
import '../../task_overview/data/models/task_detail_model.dart';
import 'models/query/query_result.dart';
import 'models/task_list_model.dart';
import 'task_api_service.dart';

// Keď niekto bude chcieť používať API, zavolá tento provider
final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskApiService(dio);
});



// Provider pre zoznam úloh (Query)
final taskListProvider = FutureProvider.autoDispose<QueryResult<TaskListModel>>((ref) async {
  final api = ref.watch(taskApiServiceProvider);
  return api.getTasks(pageNumber: 1, pageSize: 100);
});


final taskDetailProvider = FutureProvider.autoDispose.family<TaskDetailModel, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTask(taskId);
});

final taskSubtasksProvider = FutureProvider.autoDispose.family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTaskSubtasks(taskId);
});