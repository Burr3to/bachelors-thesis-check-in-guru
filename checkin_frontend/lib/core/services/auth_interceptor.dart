import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor for handling automatic JWT token injection and token rotation.
/// It catches 401 errors to attempt a silent token refresh using the HTTP-only cookie.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl;

  /// Global future to synchronize multiple concurrent refresh attempts.
  Future<String?>? _refreshTokenFuture;

  AuthInterceptor(this._dio, this._baseUrl);

  /// Injects the current JWT token into the request headers and enables credentials for web.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Required for the browser to include the refresh token cookie in the request
    options.extra['withCredentials'] = true;

    return handler.next(options);
  }

  /// Handles 401 Unauthorized responses by attempting to refresh the session token.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        String? newToken;

        // If a refresh is already in progress, wait for its result instead of starting a new one
        if (_refreshTokenFuture != null) {
          newToken = await _refreshTokenFuture;
        } else {
          // This request is the first to encounter a 401; start the refresh process
          _refreshTokenFuture = _performRefresh();
          newToken = await _refreshTokenFuture;
          _refreshTokenFuture = null;
        }

        if (newToken != null) {
          // Retry the original request using the updated token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final clonedRequest = await _dio.fetch(err.requestOptions);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        _refreshTokenFuture = null;
        // If the refresh process fails, the user must be re-authenticated manually
      }
    }
    return handler.next(err);
  }

  /// Communicates with the backend refresh endpoint to acquire a new JWT.
  Future<String?> _performRefresh() async {
    try {
      final refreshDio = Dio();
      final response = await refreshDio.post(
        '${_baseUrl}api/Auth/refresh',
        options: Options(extra: {'withCredentials': true}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        // Store the new token for subsequent requests
        await _storage.write(key: 'jwt_token', value: newToken);
        return newToken;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}