import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

/// Service managing real-time WebSocket communication via SignalR.
/// Handles task-specific updates and user-wide notifications.
class SignalRService {
  HubConnection? _hubConnection;
  final String _baseUrl;

  /// Factory function to retrieve the latest JWT token for the connection.
  final Future<String> Function() _accessTokenFactory;

  SignalRService({
    required String baseUrl,
    required Future<String> Function() accessTokenFactory,
  })  : _baseUrl = baseUrl,
        _accessTokenFactory = accessTokenFactory;

  HubConnection? get connection => _hubConnection;

  /// Initializes the connection to the SignalR Hub.
  Future<void> init() async {
    Logger.root.level = Level.ALL;

    final hubUrl = '${_baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/'}api/hubs/tasks';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      options: HttpConnectionOptions(
        accessTokenFactory: _accessTokenFactory,
      ),
    )
        .withAutomaticReconnect()
        .build();

    // Setup connection close handler
    _hubConnection!.onclose(({error}) {
    });

    try {
      await _hubConnection!.start();
    } catch (e) {
      // Silently handle startup errors; automatic reconnect will take over if configured
    }
  }

  /// Joins a specific task's room to receive updates about subtask changes.
  Future<void> joinTaskRoom(String taskId) async {
    // Wait for the connection to be established if it's currently connecting
    int attempts = 0;
    while (_hubConnection?.state != HubConnectionState.Connected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection?.state == HubConnectionState.Connected) {
      final roomName = taskId.toLowerCase().trim();
      // Invoke the server-side method to join the group
      await _hubConnection!.invoke("JoinTaskRoom", args: [roomName]);
    }
  }

  /// Leaves a specific task's room to stop receiving updates.
  Future<void> leaveTaskRoom(String taskId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.invoke("LeaveTaskRoom", args: [taskId]);
    }
  }

  /// Joins a private user room to receive dashboard-level notifications (e.g., task status updates).
  Future<void> joinUserRoom(String userId) async {
    int attempts = 0;
    while (_hubConnection?.state != HubConnectionState.Connected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection?.state == HubConnectionState.Connected) {
      final cleanId = userId.toLowerCase().trim();
      await _hubConnection!.invoke("JoinUserRoom", args: [cleanId]);
    }
  }

  /// Closes the active SignalR connection.
  void stop() {
    _hubConnection?.stop();
  }
}