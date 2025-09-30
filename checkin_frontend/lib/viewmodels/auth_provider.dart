import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:checkin_frontend/config/app_constants.dart';

// TODO: Review correctness of the UserProfile fields based on backend response.
// TODO look for more secure storage for JWT tokens
class UserProfile {
  final String userId;
  final String email;
  final String? name;
  final String jwtToken;

  // instance.
  UserProfile({required this.userId, required this.email, this.name, required this.jwtToken});
}

// A [StateNotifier] that manages the authentication state of the application.
// It handles logging in, loading user profiles from stored tokens, and logging out.
class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier() : super(null) {
    _loadUserProfile();
  }

  late SharedPreferences _prefs;

  /// `SharedPreferences` instance.
  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Attempts to load a user profile from a stored JWT token in `SharedPreferences`.
  /// If a token is found, it calls `fetchUserProfile` to validate it and get user data.
  Future<void> _loadUserProfile() async {
    await _initStorage();
    final token = _prefs.getString('jwt_token');
    if (token != null) {
      await fetchUserProfile(token);
    } else {
      // user remains logged out (state is null)
    }
  }

  /// Logs in the user by storing the provided JWT token and fetching their profile.
  Future<void> signInWithToken(String token) async {
    await _initStorage();
    await _prefs.setString('jwt_token', token);
    await fetchUserProfile(token);
  }

  void setLoginError(String message) {
    state = null;
  }

  /// Fetches the user's profile information from the backend using the provided JWT token.
  /// If successful, it updates the `state` with the new `UserProfile`.
  /// On failure, it calls `_handleError` and initiates a `signOut`.
  Future<void> fetchUserProfile(String token) async {
    final Uri profileUrl = Uri.parse(kBackendUserProfileEndpoint);

    try {
      final response = await http.get(
        profileUrl,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        state = UserProfile(
          userId: userData['id'],
          email: userData['email'],
          name: userData['name'] ?? userData['email'],
          jwtToken: token,
        );
      } else {
        // token invalid
        _handleError('Failed to load user profile: ${response.statusCode} - ${response.body}');
        await signOut();
      }
    } catch (e) {
      _handleError('Error fetching profile: $e');
      await signOut();
    }
  }

  void _handleError(String message) {
    // print('AuthNotifier Error: $message'); // For debugging
  }

  // Logs out the user by removing the JWT token from `SharedPreferences`
  Future<void> signOut() async {
    await _initStorage();
    await _prefs.remove('jwt_token');
    state = null;
  }
}

// A Riverpod `StateNotifierProvider` that exposes the `AuthNotifier`
// and its `UserProfile?` state.
// This allows widgets to listen to authentication changes and interact
// with the authentication logic.
final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});
