import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String _baseUrl;
  // ZMENA: Návratový typ musí byť Future<String>, nie String?
  final Future<String> Function() _accessTokenFactory;

  SignalRService({
    required String baseUrl,
    required Future<String> Function() accessTokenFactory,
  })  : _baseUrl = baseUrl,
        _accessTokenFactory = accessTokenFactory;

  HubConnection? get connection => _hubConnection;

  Future<void> init() async {
    Logger.root.level = Level.ALL;

    final hubUrl = '${_baseUrl.endsWith('/') ? _baseUrl : '$_baseUrl/'}hubs/tasks';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
      hubUrl,
      options: HttpConnectionOptions(
        accessTokenFactory: _accessTokenFactory,
        // logging: transportProtLogger, // voliteľné
      ),
    )
        .withAutomaticReconnect()
        .build();

    // CHYBA 1 FIX: Parameter 'error' musí byť typu Exception?
    _hubConnection!.onclose(({error}) {
      if (kDebugMode) print("SignalR Connection Closed: $error");
    });

    try {
      await _hubConnection!.start();
      if (kDebugMode) print("SignalR Connection Started");
    } catch (e) {
      if (kDebugMode) print("SignalR Start Error: $e");
    }
  }


  Future<void> joinTaskRoom(String taskId) async {
    // Ak sa práve pripája, počkáme chvíľu (max 5 sekúnd)
    int attempts = 0;
    while (_hubConnection?.state != HubConnectionState.Connected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection?.state == HubConnectionState.Connected) {
      final roomName = taskId.toLowerCase().trim();
      await _hubConnection!.invoke("JoinTaskRoom", args: [roomName]);
      print("SIGNALR: Úspešne vyvolané JoinTaskRoom pre $roomName");
    } else {
      print("SIGNALR: CHYBA - Nepodarilo sa pripojiť k serveru, JoinTaskRoom zlyhalo.");
    }
  }

  Future<void> leaveTaskRoom(String taskId) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      await _hubConnection!.invoke("LeaveTaskRoom", args: [taskId]);
    }
  }


  Future<void> joinUserRoom(String userId) async {
    int attempts = 0;
    while (_hubConnection?.state != HubConnectionState.Connected && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (_hubConnection?.state == HubConnectionState.Connected) {
      // POSIELAME IBA ID! (Prefix "User_" pridá až Backend)
      final cleanId = userId.toLowerCase().trim();
      await _hubConnection!.invoke("JoinUserRoom", args: [cleanId]);
      print("SIGNALR: Úspešne vyvolané JoinUserRoom pre ID: $cleanId");
    }
  }

  void stop() {
    _hubConnection?.stop();
  }
}