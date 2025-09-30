import 'dart:js_interop';
import 'dart:js_util';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

// Processes incoming authentication messages from the web window.
void _processAuthMessage(Map<Object?, Object?> rawDartMap, WidgetRef ref) {
  Map<String, dynamic> data = {};
  rawDartMap.forEach((key, value) {
    if (key is String) {
      data[key] = value;
    } else {}
  });

  if (data.isEmpty && rawDartMap.isNotEmpty) {
    ref
        .read(authProvider.notifier)
        .setLoginError('Neznáma chyba pri spracovaní prihlásenia (neplatný formát kľúčov dát).');
    return;
  }
  if (data.isEmpty) {
    ref
        .read(authProvider.notifier)
        .setLoginError('Neznáma chyba pri spracovaní prihlásenia (prázdne dáta).');
    return;
  }

  // Extract authentication-related fields from the processed data.
  final String? type = data['type'] as String?;
  final String? token = data['token'] as String?;
  final String? errorMessage = data['message'] as String?;

  if (type == 'loginSuccess' && token != null && token.isNotEmpty) {
    ref.read(authProvider.notifier).signInWithToken(token);
  } else if (type == 'loginError' && errorMessage != null) {
    ref.read(authProvider.notifier).setLoginError(errorMessage);
  } else {
    ref.read(authProvider.notifier).setLoginError('Prijatá neznáma správa pri prihlásení.');
  }
}

// A widget responsible for initializing and disposing a global `window.message` event listener.
class AuthListenerInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const AuthListenerInitializer({super.key, required this.child});

  @override
  ConsumerState<AuthListenerInitializer> createState() => _AuthListenerInitializerState();
}

// The state for `AuthListenerInitializer`, handling the lifecycle of the message event listener.
class _AuthListenerInitializerState extends ConsumerState<AuthListenerInitializer> {
  late JSFunction _messageListenerJsFn;

  @override
  void initState() {
    super.initState();

    // Define the Dart callback function that will be executed when a 'message' event occurs.
    void dartCallback(web.MessageEvent event) {
      final JSAny? rawData = event.data;
      // TODO check event.origin to prevent spoofing
      if (rawData == null) {
        ref.read(authProvider.notifier).setLoginError('Chyba pri prihlásení: Chýbajúce dáta.');
        return;
      }

      try {
        final dynamic dartifiedData = dartify(rawData);
        if (dartifiedData is Map<Object?, Object?>) {
          _processAuthMessage(dartifiedData, ref);
        } else {
          if (rawData is JSObject) {
            final JSAny? typeJs = getProperty(rawData, 'type');
            final JSAny? tokenJs = getProperty(rawData, 'token');
            final JSAny? messageJs = getProperty(rawData, 'message');

            final String? type = (typeJs is JSString) ? typeJs.toDart : null;
            final String? token = (tokenJs is JSString) ? tokenJs.toDart : null;
            final String? errorMessage = (messageJs is JSString) ? messageJs.toDart : null;

            if (type == 'loginSuccess' && token != null && token.isNotEmpty) {
              ref.read(authProvider.notifier).signInWithToken(token);
            } else if (type == 'loginError' && errorMessage != null) {
              ref.read(authProvider.notifier).setLoginError(errorMessage);
            } else {
              ref
                  .read(authProvider.notifier)
                  .setLoginError('Prijatá neznáma správa pri prihlásení (cez getProperty).');
            }
          } else {
            ref
                .read(authProvider.notifier)
                .setLoginError('Neznáma chyba pri spracovaní prihlásenia (neznámy typ dát).');
          }
        }
      } catch (e, st) {
        ref.read(authProvider.notifier).setLoginError('Kritická chyba pri spracovaní prihlásenia.');
      }
    }

    _messageListenerJsFn = dartCallback.toJS;
    web.window.addEventListener('message', _messageListenerJsFn);
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', _messageListenerJsFn);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
