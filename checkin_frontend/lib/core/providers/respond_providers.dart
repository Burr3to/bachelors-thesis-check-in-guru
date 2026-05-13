import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart';
import 'package:checkin_frontend/core/services/subtask_instance_api_service.dart';
import '../models/task/task_public_detail_model.dart';
import '../services/task_api_service.dart';

/// Provides an instance of the subtask instance API service.
final subtaskInstanceApiServiceProvider = Provider<SubtaskInstanceApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return SubtaskInstanceApiService(dio);
});

/// Provides an instance of the main task API service.
final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return TaskApiService(dio);
});

/// Fetches public task details and subtasks using a secure hash.
/// Used for anonymous or invited users accessing a task via link.
final publicTaskProvider = FutureProvider.family<TaskPublicDetailModel, String>((ref, hash) async {
  final apiService = ref.watch(taskApiServiceProvider);

  try {
    // Attempt to retrieve public details from the backend
    final response = await apiService.getPublicSubtasks(hash);
    return response;
  } on DioException {
    rethrow;
  } catch (e) {
    rethrow;
  }
});