import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:checkin_frontend/config/app_constants.dart';

// Predpokladaný UserProfile model
class UserProfile {
  final String userId;
  final String email;
  final String? name;
  final String jwtToken;

  UserProfile({required this.userId, required this.email, this.name, required this.jwtToken});
}

class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier() : super(null) {
    _loadUserProfile();
  }

  late SharedPreferences _prefs;

  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadUserProfile() async {
    print('AuthNotifier: Načítavam profil pri štarte...'); // DIAGNOSTIKA
    await _initStorage();
    final token = _prefs.getString('jwt_token');
    if (token != null) {
      print('AuthNotifier: Našiel som uložený token, volám fetchUserProfile.'); // DIAGNOSTIKA
      await fetchUserProfile(token);
    } else {
      print('AuthNotifier: Žiadny uložený token.'); // DIAGNOSTIKA
    }
  }

  Future<void> signInWithToken(String token) async {
    print('AuthNotifier: Volaná signInWithToken. Token začína: ${token.substring(0, 10)}...'); // DIAGNOSTIKA
    await _initStorage();
    await _prefs.setString('jwt_token', token);
    print('AuthNotifier: Token uložený v SharedPreferences, volám fetchUserProfile.'); // DIAGNOSTIKA
    await fetchUserProfile(token);
  }

  void setLoginError(String message) {
    print('AuthNotifier: Nastavujem chybu pri prihlásení: $message'); // DIAGNOSTIKA
    state = null;
  }

  Future<void> fetchUserProfile(String token) async {
    print('AuthNotifier: Volaná fetchUserProfile pre získanie detailov.'); // DIAGNOSTIKA
    final String baseUrl = kBackendBaseUrl;
    final Uri profileUrl = Uri.parse(kBackendUserProfileEndpoint);
    print('AuthNotifier: Volám backend API pre profil: $profileUrl'); // DIAGNOSTIKA

    try {
      final response = await http.get(
        profileUrl,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      print('AuthNotifier: API odpoveď z /api/User/profile - Status: ${response.statusCode}, Body: ${response.body.length > 200 ? response.body.substring(0,200) + '...' : response.body}'); // DIAGNOSTIKA

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        state = UserProfile(
          userId: userData['id'],
          email: userData['email'],
          name: userData['name'] ?? userData['email'],
          jwtToken: token,
        );
        print('AuthNotifier: Stav UserProfile aktualizovaný. Prihlásený používateľ: ${state?.email}, ID: ${state?.userId}, Token začína: ${state?.jwtToken.substring(0, 10)}...'); // DIAGNOSTIKA
      } else {
        _handleError(
          'Nepodarilo sa načítať profil používateľa: ${response.statusCode} - ${response.body}',
        );
        await signOut();
      }
    } catch (e, st) { // Pridané st pre stack trace
      _handleError('Chyba pri načítaní profilu: $e\n$st'); // DIAGNOSTIKA
      await signOut();
    }
  }

  void _handleError(String message) {
    print('AuthNotifier ERROR: $message'); // DIAGNOSTIKA
  }

  Future<void> signOut() async {
    print('AuthNotifier: Odhlasujem používateľa.'); // DIAGNOSTIKA
    await _initStorage();
    await _prefs.remove('jwt_token');
    state = null;
    print('AuthNotifier: Stav UserProfile nastavený na null.'); // DIAGNOSTIKA
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});