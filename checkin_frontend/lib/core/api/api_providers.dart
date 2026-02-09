import 'package:checkin_frontend/core/api/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/views/providers/auth_provider.dart';

// 1.
final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.createDio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Skúsime vziať token primárne z pamäte (Notifieru) - je to najrýchlejšie
        final authState = ref.read(authProvider).user;
        String? token = authState?.jwtToken;

        // 2. Ak v pamäti ešte nie je (napr. prebieha inicializácia), skúsime storage
        if (token == null) {
          final storage = ref.read(storageProvider);
          token = await storage.read(key: 'jwt_token');
        }

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print("Sending Request to: ${options.path}");
        print("With Token: ${token != null ? 'YES (Bearer ...)' : 'NO TOKEN'}");

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          print("DEBUG: Zachytená 401 pre: ${e.requestOptions.path}");

          // Ak dostaneme 401, znamená to, že náš JWT je už neplatný.
          // Musíme užívateľa odhlásiť v provideri, aby ho router hodil na login.
          ref.read(authProvider.notifier).signOut();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});