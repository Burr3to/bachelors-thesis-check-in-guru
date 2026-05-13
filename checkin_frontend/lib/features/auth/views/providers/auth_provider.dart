import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:checkin_frontend/core/models/user/user_profile.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/models/auth/auth_dtos.dart';

/// Provider for persistent secure storage.
final storageProvider = Provider((ref) => const FlutterSecureStorage());

/// Encapsulates the global authentication state.
class AuthState {
  final UserProfile? user;
  final bool isInitializing;

  AuthState({this.user, this.isInitializing = true});
}

/// Provides the authentication notifier to the rest of the application.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Manages authentication logic, syncing Firebase state with the custom backend.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthApiService _authApiService;
  late final FlutterSecureStorage _storage;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  AuthState build() {
    _authApiService = ref.read(authApiServiceProvider);
    _storage = ref.read(storageProvider);

    // Listen to Firebase auth state changes
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? firebaseUser) async {
        if (firebaseUser != null) {
          // If Firebase is authenticated, sync with our custom API
          await _authenticateWithBackend(firebaseUser);
        } else {
          // No user found, end initialization and set user to null
          state = AuthState(user: null, isInitializing: false);
        }
      },
    );

    // Clean up subscription when the provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return AuthState(isInitializing: true);
  }

  /// Exchanges a Firebase ID token for a custom backend JWT and user profile.
  Future<void> _authenticateWithBackend(User firebaseUser) async {
    try {
      final token = await firebaseUser.getIdToken();
      final response = await _authApiService.verifyFirebaseToken(
          FirebaseTokenRequest(idToken: token!));

      // Persist the custom JWT token for the Dio interceptor
      await _storage.write(key: 'jwt_token', value: response.token);

      state = AuthState(
        isInitializing: false,
        user: UserProfile(
          userId: response.userId,
          email: response.email,
          name: firebaseUser.displayName ?? 'Unknown',
          jwtToken: response.token,
        ),
      );
    } catch (e) {
      // In case of sync failure, fall back to unauthenticated state
      state = AuthState(user: null, isInitializing: false);
    }
  }

  /// Manually updates the locally stored JWT token (used during silent refreshes).
  void updateToken(String newToken) {
    if (state.user != null) {
      state = AuthState(
        isInitializing: false,
        user: UserProfile(
          userId: state.user!.userId,
          email: state.user!.email,
          name: state.user!.name,
          jwtToken: newToken,
        ),
      );
    }
  }

  /// Initiates the Google Sign-In process via a popup (Standard for Flutter Web).
  Future<void> signInWithGoogle() async {
    try {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      // The authStateChanges listener handles the subsequent backend sync
    } catch (_) {
      // Error handling is handled by the UI or general error interceptors
    }
  }

  /// Logs the user out from Firebase and cleans up local session data.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'jwt_token');
    state = AuthState(user: null, isInitializing: false);
  }
}