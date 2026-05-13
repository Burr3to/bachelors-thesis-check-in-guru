import 'package:dio/dio.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_interceptor.dart';

/// Factory class for creating and configuring the Dio HTTP client.
class DioClient {

  /// Initializes the Dio instance with base URL, timeouts, and necessary interceptors.
  static Dio createDio() {
    // Determine the environment URL based on the build mode
    final String apiUrl = kReleaseMode
        ? 'https://checkin.fit.vutbr.cz/checkin/'
        : 'https://localhost:7084/';

    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          // Accept status codes up to 299 as successful
          return status != null && status < 300;
        },
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ),
    );

    // Adds authentication management for session handling
    dio.interceptors.add(AuthInterceptor(dio, apiUrl));

    // Basic error logging for debugging API failures
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
    ));

    // Enable performance monitoring in production builds
    if (kReleaseMode) {
      dio.interceptors.add(DioFirebasePerformanceInterceptor());
    }

    return dio;
  }
}