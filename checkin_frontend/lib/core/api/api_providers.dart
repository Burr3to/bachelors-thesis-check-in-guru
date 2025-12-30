import 'package:checkin_frontend/core/api/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 1. Pridáme provider pre Storage, ak ho ešte nemáš globálne dostupný
final storageProvider = Provider((ref) => const FlutterSecureStorage());
final dioProvider = Provider<Dio>((ref) {
  // 1. Vytvoríme čistú inštanciu Dio (ako doteraz)
  final dio = DioClient.createDio();
  // 2. Získame prístup k úložisku
  //final storage = ref.watch(storageProvider);

  // 3. PRIDÁME INTERCEPTOR (Toto je tá chýbajúca časť)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // a) Prečítame token z mobilu
        final storage = ref.read(storageProvider);
        final token = await storage.read(key: 'jwt_token');

        // b) Ak token máme, pridáme ho do hlavičky
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // c) Log pre kontrolu (uvidíš to v konzole)
        print("Seding Request to: ${options.path}");
        print("With Token: ${token != null ? 'YES (Bearer ...)' : 'NO TOKEN'}");

        // d) Pokračujeme v požiadavke
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Tu môžeme odchytiť 401 a napr. odhlásiť užívateľa, ak vypršal token
        // Ak dostaneš 401, len to logni, nevyvolávaj tu žiadne globálne zmeny stavu
        if (e.response?.statusCode == 401) {
          print("DEBUG: Zachytená 401 v interceptore pre: ${e.requestOptions.path}");
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
