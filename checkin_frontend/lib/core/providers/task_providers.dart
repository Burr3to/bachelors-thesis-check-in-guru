import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart'; // Import dioProvider
import '../../features/task_overview/data/models/subtask_combined_list_model.dart';
import '../../features/task_overview/data/models/task_detail_model.dart';
import '../../features/task_list/data/models/query/query_result.dart';
import '../../features/task_list/data/models/task_list_model.dart';
import '../services/task_api_service.dart';

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

final taskTemplatesProvider = FutureProvider.autoDispose.family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTemplates(taskId);
});

final taskInstancesProvider = FutureProvider.autoDispose.family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getInstances(taskId);
});