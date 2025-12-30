import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart'; // Tu máš Dio
import 'package:checkin_frontend/features/task_respond/data/subtask_instance_api_service.dart';

import '../../../core/models/task/task_public_detail_model.dart';
import '../../auth/views/providers/auth_provider.dart';
import '../../task_list/data/task_api_service.dart';
import '../../task_overview/data/models/subtask_combined_list_model.dart'; // Ak máš getPublicSubtasks tu

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
  // 1. Sledujeme auth stav. Ak sa zmení (login/logout), tento provider sa spustí znova.
  final auth = ref.watch(authProvider);
  final apiService = ref.watch(taskApiServiceProvider);

  // Voliteľné: Ak chceš Dio-u povedať, aby pri 401 nevyhadzoval chybu, ale vrátil response
  // (to by úplne zastavilo tie "DioException" loopy), ale 401 je OK, ak ju vieme chytiť.

  return apiService.getPublicSubtasks(hash);
});