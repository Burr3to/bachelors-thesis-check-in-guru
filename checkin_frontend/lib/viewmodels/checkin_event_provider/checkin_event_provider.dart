import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model.dart';
import 'package:checkin_frontend/services/checkin_event_service.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

part 'checkin_event_provider.g.dart';


// Provides an instance of `CheckInEventService`.
// This provider watches the `authProvider` to get the current authentication state.
// User loggin in > creates a `CheckInEventService` with the JWT token and user ID.
// User not logged in > returns a service with empty credentials
@riverpod
CheckInEventService checkInEventService(Ref ref) {
  final authState = ref.watch(authProvider);

  if (authState == null) {
    return CheckInEventService(jwtToken: '', ownerId: '');
  }

  return CheckInEventService(jwtToken: authState.jwtToken, ownerId: authState.userId);
}

@riverpod
Future<List<CheckInEventListModel>> checkInEvents(Ref ref) async {
  final authState = ref.watch(authProvider);

  if (authState == null) {
    return [];
  }

  final service = ref.watch(checkInEventServiceProvider);
  return service.getMyCheckInEvents();
}
