import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import '../services/signalr_service.dart';
import 'package:flutter/foundation.dart';

final signalRProvider = Provider<SignalRService>((ref) {
  final authState = ref.watch(authProvider);

  final String baseUrl = kReleaseMode
      ? 'https://checkin.fit.vutbr.cz/checkin/'
      : 'https://localhost:7084/';

  final service = SignalRService(
    baseUrl: baseUrl,
    accessTokenFactory: () async {
      final token = authState.user?.jwtToken;
      return token ?? "";
    },
  );

  // Inicializácia pri vytvorení
  service.init();

  ref.onDispose(() => service.stop());

  return service;
});