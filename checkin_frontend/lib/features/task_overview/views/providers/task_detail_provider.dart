import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/tasks/data/task_api_service.dart';

// 1. IMPORTUJ SPRÁVNY PROVIDER Z CORE
import 'package:checkin_frontend/core/api/api_providers.dart';

import '../../data/models/subtask_combined_list_model.dart';
import '../../data/models/task_detail_model.dart';
// (alebo kde presne máš ten súbor s 'final dioProvider = ...')

// Poznámka: Tu už NEVYTVÁRAJ 'final dioProvider = ...', použi ten importovaný.

final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  // Teraz ref.watch(dioProvider) vráti tú verziu s Auth Interceptorom
  final dio = ref.watch(dioProvider);
  return TaskApiService(dio);
});

final taskDetailProvider = FutureProvider.autoDispose.family<TaskDetailModel, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTask(taskId);
});

final taskSubtasksProvider = FutureProvider.autoDispose.family<List<SubtaskCombinedListModel>, String>((ref, taskId) async {
  final apiService = ref.watch(taskApiServiceProvider);
  return apiService.getTaskSubtasks(taskId);
});