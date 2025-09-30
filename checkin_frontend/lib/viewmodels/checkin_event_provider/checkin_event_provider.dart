import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model.dart';
import 'package:checkin_frontend/services/checkin_event_service.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

part 'checkin_event_provider.g.dart';

@riverpod
CheckInEventService checkInEventService(CheckInEventServiceRef ref) {
  final authState = ref.watch(authProvider);
  print('checkInEventService provider: authState sa zmenil. Aktuálny stav: ${authState != null ? 'prihlásený' : 'odhlásený'}'); // DIAGNOSTIKA

  if (authState == null) {
    print('checkInEventService provider: Používateľ odhlásený, vraciam fiktívnu službu.'); // DIAGNOSTIKA
    return CheckInEventService(jwtToken: '', ownerId: '');
  }

  print('checkInEventService provider: Používateľ prihlásený, vytváram službu s userId: ${authState.userId}, token začína: ${authState.jwtToken.substring(0,10)}...'); // DIAGNOSTIKA
  return CheckInEventService(jwtToken: authState.jwtToken, ownerId: authState.userId);
}

@riverpod
Future<List<CheckInEventListModel>> checkInEvents(CheckInEventsRef ref) async {
  final authState = ref.watch(authProvider);
  print('checkInEvents provider: authState sa zmenil. Aktuálny stav: ${authState != null ? 'prihlásený' : 'odhlásený'}'); // DIAGNOSTIKA

  if (authState == null) {
    print('checkInEvents provider: Používateľ odhlásený, vraciam prázdny zoznam udalostí.'); // DIAGNOSTIKA
    return [];
  }

  print('checkInEvents provider: Používateľ prihlásený, pokúšam sa načítať udalosti.'); // DIAGNOSTIKA
  final service = ref.watch(checkInEventServiceProvider);
  // Môžete pridať print pre overenie, či je služba inicializovaná s platnými údajmi
  // (alebo už to vidíme z checkInEventService providera)
  return service.getMyCheckInEvents();
}