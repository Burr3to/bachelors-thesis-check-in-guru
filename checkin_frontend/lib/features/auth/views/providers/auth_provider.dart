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

class AuthState {
  final UserProfile? user;
  final bool isInitializing;

  AuthState({this.user, this.isInitializing = true});
}

// ZMENA: NotifierProvider teraz spravuje <AuthNotifier, AuthState> namiesto UserProfile?
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthApiService _authApiService;
  late final FlutterSecureStorage _storage;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  AuthState build() {
    _authApiService = ref.read(authApiServiceProvider);
    _storage = ref.read(storageProvider);

    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (User? firebaseUser) async {
        if (firebaseUser != null) {
          await _authenticateWithBackend(firebaseUser);
        } else {
          state = AuthState(user: null, isInitializing: false);
        }
      },
    );

    ref.onDispose(() {
      _authStateSubscription?.cancel();
      print("AuthNotifier bol zrušený a subscription uzavretý.");
    });

    return AuthState(isInitializing: true); // Štartujeme v stave loading
  }

  Future<void> _authenticateWithBackend(User firebaseUser) async {
    try {
      final token = await firebaseUser.getIdToken();
      final response = await _authApiService.verifyFirebaseToken(
          FirebaseTokenRequest(idToken: token!));

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
      state = AuthState(user: null, isInitializing: false);
    }
  }

  void updateToken(String newToken) {
    if (state.user != null) {
      state = AuthState(
        isInitializing: false,
        user: UserProfile(
          userId: state.user!.userId,
          email: state.user!.email,
          name: state.user!.name,
          jwtToken: newToken, // Tu priradíme nový token
        ),
      );
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


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'jwt_token');
    state = AuthState(user: null, isInitializing: false);
  }
}