import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:checkin_frontend/models/checkin_event/checkin_event_list_model'
    '.dart';
import 'package:checkin_frontend/services/checkin_event_service.dart';

part 'checkin_event_provider.g.dart';

// Provider, ktorý poskytuje inštanciu CheckInEventService
final checkInEventServiceProvider = Provider((ref) => CheckInEventService());

// FutureProvider, ktorý asynchrónne získa zoznam eventov
// a automaticky spravuje stavy (Loading, Error, Data)
@riverpod
Future<List<CheckInEventListModel>> checkInEvents(Ref ref) async {
  // Získa inštanciu služby
  final service = ref.read(checkInEventServiceProvider);

  // Vráti výsledok asynchrónneho volania
  return service.getMyCheckInEvents();
}
