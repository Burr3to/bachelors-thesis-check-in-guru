import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth/auth_dtos.dart';

part 'auth_api_service.g.dart';

/// API service interface for authentication-related requests.
/// This service is used to communicate with the backend auth controllers.
@RestApi()
sealed class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  /// Sends the Firebase ID token to the C# backend for verification.
  /// If successful, the backend returns a custom JWT and user profile information.
  @POST('api/Auth/verify-firebase-token')
  Future<AuthResponse> verifyFirebaseToken(@Body() FirebaseTokenRequest body);
}