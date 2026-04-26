import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl;
  Future<String?>? _refreshTokenFuture;

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
    if (err.response?.statusCode == 401) {
      try {
        String? newToken;

        // Ak už iný request spustil refresh, počkáme naň
        if (_refreshTokenFuture != null) {
          newToken = await _refreshTokenFuture;
        } else {
          // Sme prví! Spustíme refresh a uložíme Future do premennej
          _refreshTokenFuture = _performRefresh();
          newToken = await _refreshTokenFuture;
          _refreshTokenFuture = null; // Po dokončení vynulujeme
        }

        if (newToken != null) {
          // Zopakuj pôvodný request s novým tokenom
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final clonedRequest = await _dio.fetch(err.requestOptions);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        _refreshTokenFuture = null;
        print("Refresh failed: $e");
        // Tu môžeš pridať logiku na logout (napr. cez ref.read(authProvider.notifier).signOut())
      }
    }
    return handler.next(err);
  }

  Future<String?> _performRefresh() async {
    try {
      final refreshDio = Dio();
      final response = await refreshDio.post(
        '${_baseUrl}api/Auth/refresh',
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        await _storage.write(key: 'jwt_token', value: newToken);
        return newToken;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}