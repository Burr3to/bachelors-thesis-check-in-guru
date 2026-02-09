import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Import tvojho vygenerovaného servisu
import 'auth_api_service.dart';

// Import tvojho globálneho Dio providera (podľa tvojej štruktúry)
import '../../../core/api/api_providers.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  // 1. Získame inštanciu Dio z globálneho providera
  final Dio dio = ref.watch(dioProvider);

  // 2. Vložíme ju do Retrofit servisu
  return AuthApiService(dio);
});
