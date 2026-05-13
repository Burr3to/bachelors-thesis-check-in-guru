/// Represents the local profile of an authenticated user.
/// This model holds basic identification information and the active session token.
class UserProfile {
  /// The unique identifier of the user (maps to UserEntity.Id in the backend).
  final String userId;
  final String email;
  final String name;

  /// The current JSON Web Token used for authenticating API requests.
  final String jwtToken;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    required this.jwtToken,
  });

  /// Convenience factory to initialize a [UserProfile] from backend authentication data.
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