// lib/config/app_constants.dart

// Backend URLs
const String kBackendBaseUrl = 'https://localhost:7084';
const String kBackendGoogleLoginEndpoint = '$kBackendBaseUrl/api/Auth/google-login';
const String kBackendUserProfileEndpoint = '$kBackendBaseUrl/api/User/profile';
const String kBackendCheckInEventBaseEndpoint = '$kBackendBaseUrl/api/CheckInEvent';

// Frontend
const String kFrontendBaseUrl = 'http://localhost:5000';

// GoRouter
const String kRouteHome = '/';
const String kRouteCheckInEvents = '/CheckInEvents';
const String kRouteLoginSuccess = '/login-success';

// NavBar cesty (ako to máte teraz)
const List<String> navBarPaths = [
  kRouteHome,
  kRouteCheckInEvents,
];