import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';
import '../services/signalr_service.dart';
import 'package:flutter/foundation.dart';

/// Configures and manages the SignalR connection for real-time updates.
final signalRProvider = Provider<SignalRService>((ref) {
  final authState = ref.watch(authProvider);

  // Determine backend URL based on build mode
  final String baseUrl = kReleaseMode
      ? 'https://checkin.fit.vutbr.cz/checkin/'
      : 'https://localhost:7084/';

  // Create service instance with dynamic token retrieval
  final service = SignalRService(
    baseUrl: baseUrl,
    accessTokenFactory: () async {
      // Provide the current JWT token for SignalR authentication
      final token = authState.user?.jwtToken;
      return token ?? "";
    },
  );

  // Initialize connection logic upon provider creation
  service.init();

  // Ensure the connection is closed when the provider is destroyed
  ref.onDispose(() => service.stop());

  return service;
});