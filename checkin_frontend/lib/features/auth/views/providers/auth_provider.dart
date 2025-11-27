import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:checkin_frontend/core/models/user/user_profile.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_providers.dart'; // Import providera pre service
import '../../data/models/auth_dtos.dart';

// Provider pre Storage (aby sme mohli ukladať token)
final storageProvider = Provider((ref) => const FlutterSecureStorage());

final authProvider = NotifierProvider<AuthNotifier, UserProfile?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserProfile?> {
  late final AuthApiService _authApiService;
  late final FlutterSecureStorage _storage;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  UserProfile? build() {
    _authApiService = ref.read(authApiServiceProvider);
    _storage = ref.read(storageProvider);

    // Počúvame Firebase zmeny
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? firebaseUser) {
        if (firebaseUser != null) {
          _authenticateWithBackend(firebaseUser);
        } else {
          _logoutLocally();
        }
      },
      onError: (error) {
        print("Firebase Auth Error: $error");
        state = null;
      },
    );

    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return null;
  }

  /// Výmena Firebase Tokenu za Backend JWT
  Future<void> _authenticateWithBackend(User firebaseUser) async {
    try {
      // 1. Získaj ID Token z Firebase
      final String? firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null) return;

      // 2. Pošli ho na C# Backend cez Retrofit
      // response je typu AuthResponse (token, userId, email)
      final AuthResponse response = await _authApiService.verifyFirebaseToken(
        FirebaseTokenRequest(idToken: firebaseIdToken),
      );

      // 3. ULOŽ JWT TOKEN (Aby fungoval Interceptor)
      // Ukladáme 'response.token', lebo tak sa to volá v DTO z backendu
      await _storage.write(key: 'jwt_token', value: response.token);

      // 4. Nastav state (UserProfile)
      // TU BOLA CHYBA: Musíš použiť názvy parametrov z UserProfile
      state = UserProfile(
        userId: response.userId,          // DTO má .userId -> UserProfile chce userId
        email: response.email,            // DTO má .email -> UserProfile chce email
        name: firebaseUser.displayName ?? 'Unknown',
        jwtToken: response.token,         // DTO má .token -> UserProfile chce jwtToken
      );

    } catch (e) {
      print("Chyba pri overovaní na backende: $e");
      await FirebaseAuth.instance.signOut();
      state = null;
    }
  }

  /// Google Sign In (Trigger z UI)
  Future<void> signInWithGoogle() async {
    try {
      // Pre WEB stačí toto, otvorí to Popup okno
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      // Zvyšok rieši listener v build() metóde
    } catch (e) {
      print("Google Sign In Error: $e");
    }
  }

  /// Logout
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _logoutLocally();
  }

  Future<void> _logoutLocally() async {
    await _storage.delete(key: 'jwt_token'); // Vymaž token
    state = null;
  }
}