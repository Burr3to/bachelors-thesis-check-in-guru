import 'package:freezed_annotation/freezed_annotation.dart';

// Tieto názvy musia sedieť s názvom súboru
part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

// 1. Čo posielame na Backend
@freezed
sealed class FirebaseTokenRequest with _$FirebaseTokenRequest {
  const factory FirebaseTokenRequest({
    required String idToken,
  }) = _FirebaseTokenRequest;

  factory FirebaseTokenRequest.fromJson(Map<String, dynamic> json) => _$FirebaseTokenRequestFromJson(json);
}

// 2. Čo dostaneme z Backendu
@freezed
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required String userId,
    required String email,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}