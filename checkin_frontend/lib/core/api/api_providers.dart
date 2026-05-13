import 'package:checkin_frontend/core/api/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/providers/auth_provider.dart';

/// Global future to track the token refresh process.
/// Prevents multiple simultaneous 401 errors from triggering multiple refresh requests.
Future<String?>? _refreshFuture;

/// Provides a configured Dio instance with automatic JWT injection and token refresh logic.
final dioProvider = Provider<Dio>((ref) {
  final dio = DioClient.createDio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(storageProvider);
        final token = await storage.read(key: 'jwt_token');

        // Inject the JWT token into the Authorization header if available
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Essential for web: allows the browser to include HttpOnly cookies (refresh token)
        options.extra['withCredentials'] = true;

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized errors, unless the error came from the refresh endpoint itself
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('refresh')) {

          // If a refresh is already in progress, wait for it to complete
          if (_refreshFuture != null) {
            final newToken = await _refreshFuture;

            if (newToken != null) {
              // Retry the original request with the newly acquired token
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          }

          try {
            // Initialize the refresh process and store the future globally
            _refreshFuture = () async {
              final refreshDio = Dio(BaseOptions(baseUrl: e.requestOptions.baseUrl));
              final response = await refreshDio.post(
                'api/Auth/refresh',
                options: Options(extra: {'withCredentials': true}),
              );
              return response.data['token'] as String?;
            }();

            final newToken = await _refreshFuture;
            _refreshFuture = null;

            if (newToken != null) {
              // Update local storage and auth state with the new token
              await ref.read(storageProvider).write(key: 'jwt_token', value: newToken);
              ref.read(authProvider.notifier).updateToken(newToken);

              // Retry the original request with the new token
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(e.requestOptions);
              return handler.resolve(response);
            }
          } catch (refreshError) {
            _refreshFuture = null;
            // If refresh fails, log the user out to ensure security
            ref.read(authProvider.notifier).signOut();
          }
        }

        return handler.next(e);
      },
    ),
  );

  return dio;
});