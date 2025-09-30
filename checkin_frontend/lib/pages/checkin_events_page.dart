// lib/pages/checkin_events_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/viewmodels/checkin_event_provider/checkin_event_provider.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

/// Displaying the user's Check-In events.
/// Requires user authentication. If the user is not logged in,
/// it displays a prompt to log in.
/// It fetches events using `checkInEventsProvider` and displays them in a list.
class CheckInEventsPage extends ConsumerWidget {
  const CheckInEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // User is not logged in
    if (authState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Events')),
        body: const Center(
          child: Text('Please log in to create events.', textAlign: TextAlign.center),
        ),
      );
    }

    final eventsAsyncValue = ref.watch(checkInEventsProvider);
    
    //User is logged in
    return Scaffold(
      appBar: AppBar(title: const Text('My Check-In Events')),
      body: eventsAsyncValue.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          return Center(child: Text('Error loading events: $err'));
        },
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text(
                'You have no Check-In Events. Create the first one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          // List of events
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              // TODO: fix checkin_event_list_model to include Notes
              return ListTile(
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  'Date: ${event.createdAt.toLocal().toShortDateString()}',
                ),
              );
            },
          );
        },
      ),
      // FloatingActionButton for refresh
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Invalidate the provider to force a refresh of the event list.
          ref.invalidate(checkInEventsProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${year}';
  }
}
