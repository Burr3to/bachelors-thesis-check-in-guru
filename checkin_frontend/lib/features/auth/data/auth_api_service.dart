import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'models/auth_dtos.dart';

part 'auth_api_service.g.dart';

@RestApi()
sealed class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  // Volanie na tvoj C# endpoint
  @POST('/api/Auth/verify-firebase-token')
  Future<AuthResponse> verifyFirebaseToken(@Body() FirebaseTokenRequest body);
}