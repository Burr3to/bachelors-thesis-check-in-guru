import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ak budeš chcieť provider

class DioClient {
  // Singleton alebo len getter, záleží ako to chceš používať.
  // Pre Riverpod je lepšie to mať ako Provider.

  static Dio createDio() {
    final String apiUrl = kReleaseMode
        //? 'https://checkin.fit.vutbr.cz' // Produkčná URL (zmeníš podľa servera)
        ? 'https://checkin-backend-bp.azurewebsites.net'
        : 'https://localhost:7084'; // Lokálna URL pre vývoj

    final dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Pridáme Interceptor na logovanie (aby si videl v konzole čo sa deje)
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }
}
