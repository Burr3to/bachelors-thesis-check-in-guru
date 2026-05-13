import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/auth_api_service.dart';
import '../api/api_providers.dart';

/// Provides an instance of AuthApiService configured with the global Dio client.
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  // Retrieve the global Dio instance which includes auth interceptors
  final Dio dio = ref.watch(dioProvider);

  // Initialize and return the Retrofit-generated Auth API service
  return AuthApiService(dio);
});