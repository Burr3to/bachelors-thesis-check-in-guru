// lib/pages/checkin_events_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/viewmodels/checkin_event_provider/checkin_event_provider.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart'; // Dôležité: Uistite sa, že tento import je prítomný

class CheckInEventsPage extends ConsumerWidget {
  const CheckInEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sledujeme stav authProvider pre rozhodnutie o zobrazení obsahu
    final authState = ref.watch(authProvider);
    print('CheckInEventsPage: build volaný. Aktuálny authState je ${authState != null ? 'prihlásený (${authState.email})' : 'odhlásený'}'); // DIAGNOSTIKA

    // Ak používateľ nie je prihlásený, zobrazíme výzvu na prihlásenie
    if (authState == null) {
      print('CheckInEventsPage: Používateľ nie je prihlásený, zobrazujem výzvu na prihlásenie.'); // DIAGNOSTIKA
      return Scaffold(
        appBar: AppBar(title: const Text('Moje udalosti')), // Pridaný AppBar
        body: const Center(
          child: Text('Pre zobrazenie udalostí sa prosím prihláste.', textAlign: TextAlign.center),
        ),
      );
    }

    // Až teraz, keď je používateľ prihlásený, sledujeme eventy.
    final eventsAsyncValue = ref.watch(checkInEventsProvider);
    print('CheckInEventsPage: Používateľ prihlásený, sledujem checkInEventsProvider. Aktuálny stav: ${eventsAsyncValue.runtimeType}'); // DIAGNOSTIKA

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Check-In Udalosti'), // AppBar pre prihláseného používateľa
      ),
      body: eventsAsyncValue.when(
        loading: () {
          print('CheckInEventsPage: Načítavam udalosti...'); // DIAGNOSTIKA
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          print('CheckInEventsPage: Chyba pri načítaní udalostí: $err\n$stack'); // DIAGNOSTIKA
          return Center(child: Text('Chyba pri načítaní: $err'));
        },
        data: (events) {
          print('CheckInEventsPage: Dáta prijaté: ${events.length} udalostí.'); // DIAGNOSTIKA
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'Nemáte žiadne Check-In Eventy. Vytvorte prvý!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Zobrazenie zoznamu eventov (ListView)
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              // Prispôsobenie podľa CheckInEventListModel, predpokladám 'name' je title a 'id' + 'description' sú subtitle
              return ListTile(
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('ID: ${event.id}\n'),
                trailing: Text(
                  'Dátum: ${event.createdAt.toLocal().toShortDateString()}', // Používame 
                  // toShortDateString z extension
                ),
              );
            },
          );
        },
      ),
      // Pridávam FloatingActionButton pre refresh (ako v predchádzajúcom návrhu)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('CheckInEventsPage: Stlačené tlačidlo obnoviť, zneplatňujem checkInEventsProvider.'); // DIAGNOSTIKA
          ref.invalidate(checkInEventsProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Pomocná extension pre DateTime, ak ju ešte nemáte
// Umiestnite ju ideálne do samostatného súboru, napr. `lib/utils/date_extensions.dart`
// alebo na koniec tohto súboru pre jednoduchosť.
extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${year}';
  }
}