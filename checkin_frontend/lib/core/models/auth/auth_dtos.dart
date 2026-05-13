import 'package:freezed_annotation/freezed_annotation.dart';

// These parts are required for the code generation (Freezed and JsonSerializable)
part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

/// Data Transfer Object representing the request sent to the backend
/// to verify a Firebase ID token.
@freezed
sealed class FirebaseTokenRequest with _$FirebaseTokenRequest {
  const factory FirebaseTokenRequest({
    required String idToken,
  }) = _FirebaseTokenRequest;

  /// Creates a FirebaseTokenRequest instance from a JSON map.
  factory FirebaseTokenRequest.fromJson(Map<String, dynamic> json) => _$FirebaseTokenRequestFromJson(json);
}

/// Data Transfer Object representing the authentication response received
/// from the backend after a successful login or token verification.
@freezed
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required String userId,
    required String email,
  }) = _AuthResponse;

  /// Creates an AuthResponse instance from a JSON map.
  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}