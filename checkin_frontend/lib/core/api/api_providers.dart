import 'package:checkin_frontend/core/api/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/providers/auth_provider.dart';

// Premenná mimo providera zabezpečí, že ak prebieha refresh,
// ostatné 401-ky naň počkajú a nebudú búchať do servera naraz.
Future<String?>? _refreshFuture;

final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.createDio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(storageProvider);
        final token = await storage.read(key: 'jwt_token');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // KĽÚČOVÉ PRE WEB: Pribalenie Cookies k requestu
        options.extra['withCredentials'] = true;

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Ak dostaneme 401 a nie je to chyba samotného refreshu
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('refresh')) {

          // 1. AK UŽ REFRESH PREBIEHA (z iného requestu), POČKAJ NAŇ
          if (_refreshFuture != null) {
            final newToken = await _refreshFuture;

            if (newToken != null) {
              // Počkali sme, máme nový token, skúsime pôvodný request znova
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          }


          try {
            // Vytvoríme Future pre refresh a uložíme ho do globálnej premennej
            _refreshFuture = () async {
              final refreshDio = Dio(BaseOptions(baseUrl: e.requestOptions.baseUrl));
              final response = await refreshDio.post(
                'api/Auth/refresh',
                options: Options(extra: {'withCredentials': true}),
              );
              return response.data['token'] as String?;
            }();

            final newToken = await _refreshFuture;
            _refreshFuture = null; // Po úspechu vynulujeme premennú

            if (newToken != null) {
              // Uložíme nový token všade, kde treba
              await ref.read(storageProvider).write(key: 'jwt_token', value: newToken);
              ref.read(authProvider.notifier).updateToken(newToken);

              // Zopakujeme pôvodný request s novým tokenom
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          } catch (refreshError) {
            _refreshFuture = null; // Aj pri chybe musíme vynulovať premennú
            print("Refresh zlyhal definitívne, odhlasujem... $refreshError");
            ref.read(authProvider.notifier).signOut();
          }
        }

        return handler.next(e);
      },
    ),
  );

  return dio;
});