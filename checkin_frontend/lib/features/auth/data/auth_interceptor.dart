import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl;

  AuthInterceptor(this._dio, this._baseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Pridaj JWT token do každého requestu
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // DÔLEŽITÉ PRE WEB: Aby Dio posielalo cookies
    options.extra['withCredentials'] = true;

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 2. Ak dostaneme 401, skúsime refresh
    if (err.response?.statusCode == 401) {
      try {
        // Zavolaj tvoj refresh endpoint
        // Poznámka: Použi novú inštanciu Dio, aby si sa vyhol nekonečnej slučke
        final refreshDio = Dio();
        final response = await refreshDio.post(
          '$_baseUrl/api/Auth/refresh',
          options: Options(extra: {'withCredentials': true}),
        );

        if (response.statusCode == 200) {
          final newToken = response.data['token'];
          await _storage.write(key: 'jwt_token', value: newToken);

          // Zopakuj pôvodný request s novým tokenom
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final clonedRequest = await _dio.fetch(err.requestOptions);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        // Ak refresh zlyhá (napr. vypršal aj refresh token), odhlás používateľa
        print("Refresh failed: $e");
      }
    }
    return handler.next(err);
  }
}