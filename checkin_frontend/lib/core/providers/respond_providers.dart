import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart'; // Tu máš Dio
import 'package:checkin_frontend/core/services/subtask_instance_api_service.dart';

import '../models/task/task_public_detail_model.dart';
import '../services/task_api_service.dart';
// Ak máš getPublicSubtasks tu

// 1. Provider pre SubtaskInstanceApiService (na odoslanie BulkComplete)
final subtaskInstanceApiServiceProvider = Provider<SubtaskInstanceApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return SubtaskInstanceApiService(dio);
});

// 2. Provider pre načítanie verejných dát podľa Hashu
// Tento používa TaskApiService (ak si getPublicSubtasks pridal tam)
final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskApiService(dio);
});

final publicTaskProvider = FutureProvider.family<TaskPublicDetailModel, String>((ref, hash) async {
  final apiService = ref.watch(taskApiServiceProvider);

  try {
    final response = await apiService.getPublicSubtasks(hash);
    return response;
  } on DioException {
    rethrow;
  } catch (e) {
    rethrow;
  }
});