import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/core/api/api_providers.dart'; // Import dioProvider
import 'task_api_service.dart';

// Keď niekto bude chcieť používať API, zavolá tento provider
final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  // Získame naše globálne Dio
  final dio = ref.watch(dioProvider);
  // A vložíme ho do servisu
  return TaskApiService(dio);
});