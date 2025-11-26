// lib/core/models/user_profile.dart

class UserProfile {
  // Primárne ID (Zhodné s UserEntity.Id)
  final String userId;
  final String email;
  final String name;
  final String jwtToken;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    required this.jwtToken,
  });

  // Metóda pre pohodlné vytvorenie z API odpovede (ak API vráti meno/email/ID)
  factory UserProfile.fromApi({
    required String token,
    required String id,
    required String email,
    required String name
  }) {
    return UserProfile(
        userId: id,
        email: email,
        name: name,
        jwtToken: token
    );
  }
}