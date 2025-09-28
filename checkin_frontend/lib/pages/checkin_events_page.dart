import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/viewmodels/checkin_event_provider/checkin_event_provider.dart';

class CheckInEventsPage extends ConsumerWidget {
  const CheckInEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sledujeme stav dát pomocou AsyncValue
    final eventsAsyncValue = ref.watch(checkInEventsProvider);

    return Scaffold(
      body: eventsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, stack) => Center(child: Text('Chyba pri načítaní: $err')),

        data: (events) {
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
              return ListTile(
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('ID: ${event.id}\nHash: ${event.hash}'),
                trailing: Text(
                  'Vytvorené: ${event.createdAt.toLocal().toString().substring(0, 10)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
