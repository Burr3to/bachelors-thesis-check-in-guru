import 'dart:js_interop';
import 'dart:js_util';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/viewmodels/auth_provider.dart';

// Pomocná funkcia na spracovanie prijatej správy
void _processAuthMessage(Map<Object?, Object?> rawDartMap, WidgetRef ref) {
  print('AuthListenerInitializer: _processAuthMessage called with rawDartMap: $rawDartMap'); // DIAGNOSTIKA
  Map<String, dynamic> data = {};
  rawDartMap.forEach((key, value) {
    if (key is String) {
      data[key] = value;
    } else {
      print('AuthListenerInitializer: ERROR: Kľúč prijatých dát nie je typu String: $key. Ignorujem.'); // DIAGNOSTIKA
    }
  });

  if (data.isEmpty && rawDartMap.isNotEmpty) {
    print('AuthListenerInitializer: ERROR: Konvertované dáta sú prázdne, hoci pôvodné neboli. Možno neplatné kľúče.'); // DIAGNOSTIKA
    ref.read(authProvider.notifier).setLoginError('Neznáma chyba pri spracovaní prihlásenia (neplatný formát kľúčov dát).');
    return;
  }
  if (data.isEmpty) {
    print('AuthListenerInitializer: ERROR: Prijaté dáta sú prázdne.'); // DIAGNOSTIKA
    ref.read(authProvider.notifier).setLoginError('Neznáma chyba pri spracovaní prihlásenia (prázdne dáta).');
    return;
  }

  final String? type = data['type'] as String?;
  final String? token = data['token'] as String?;
  final String? errorMessage = data['message'] as String?;

  print('AuthListenerInitializer: Parsed message type: $type, token: ${token != null ? 'present' : 'null'}, message: $errorMessage'); // DIAGNOSTIKA

  if (type == 'loginSuccess' && token != null && token.isNotEmpty) {
    print('AuthListenerInitializer: Volám signInWithToken s prijatým tokenom.'); // DIAGNOSTIKA
    ref.read(authProvider.notifier).signInWithToken(token);
  } else if (type == 'loginError' && errorMessage != null) {
    print('AuthListenerInitializer: Volám setLoginError s chybovou správou.'); // DIAGNOSTIKA
    ref.read(authProvider.notifier).setLoginError(errorMessage);
  } else {
    print('AuthListenerInitializer: Prijatá neznáma správa, alebo chýba type/token/message.'); // DIAGNOSTIKA
    ref.read(authProvider.notifier).setLoginError('Prijatá neznáma správa pri prihlásení.');
  }
}

class AuthListenerInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AuthListenerInitializer({super.key, required this.child});

  @override
  ConsumerState<AuthListenerInitializer> createState() => _AuthListenerInitializerState();
}

class _AuthListenerInitializerState extends ConsumerState<AuthListenerInitializer> {
  late JSFunction _messageListenerJsFn;

  @override
  void initState() {
    super.initState();
    print('AuthListenerInitializer: Inicializujem listener pre postMessage udalosti...');

    void dartCallback(web.MessageEvent event) {
      print('AuthListenerInitializer: Prijatá postMessage udalosť.'); // DIAGNOSTIKA
      print('AuthListenerInitializer: Origin správy: ${event.origin}'); // DIAGNOSTIKA
      final JSAny? rawData = event.data;

      if (rawData == null) {
        print('AuthListenerInitializer: ERROR: event.data je null.'); // DIAGNOSTIKA
        ref.read(authProvider.notifier).setLoginError('Chyba pri prihlásení: Chýbajúce dáta.');
        return;
      }

      print('AuthListenerInitializer: Raw event.data typu: ${rawData.runtimeType}.'); // DIAGNOSTIKA

      try {
        final dynamic dartifiedData = dartify(rawData);
        if (dartifiedData is Map<Object?, Object?>) {
           print('AuthListenerInitializer: dartify úspešne konvertoval dáta na Map<Object?, Object?>.'); // DIAGNOSTIKA
           _processAuthMessage(dartifiedData, ref);
        } else {
           print('AuthListenerInitializer: UPOZORNENIE: dartify nevrátil Map<Object?, Object?> (vrátil ${dartifiedData.runtimeType}). Skúšam priamy prístup cez JSObject.'); // DIAGNOSTIKA
           if (rawData is JSObject) {
              final JSAny? typeJs = getProperty(rawData, 'type');
              final JSAny? tokenJs = getProperty(rawData, 'token');
              final JSAny? messageJs = getProperty(rawData, 'message');

              final String? type = (typeJs is JSString) ? typeJs.toDart : null;
              final String? token = (tokenJs is JSString) ? tokenJs.toDart : null;
              final String? errorMessage = (messageJs is JSString) ? messageJs.toDart : null;

              print('AuthListenerInitializer: Priamy JS prístup parsovaný: typ: $type, token: ${token != null ? 'present' : 'null'}, message: $errorMessage'); // DIAGNOSTIKA

              if (type == 'loginSuccess' && token != null && token.isNotEmpty) {
                print('AuthListenerInitializer: Volám signInWithToken (cez getProperty).'); // DIAGNOSTIKA
                ref.read(authProvider.notifier).signInWithToken(token);
              } else if (type == 'loginError' && errorMessage != null) {
                print('AuthListenerInitializer: Volám setLoginError (cez getProperty).'); // DIAGNOSTIKA
                ref.read(authProvider.notifier).setLoginError(errorMessage);
              } else {
                print('AuthListenerInitializer: ERROR: Neznáma/neplatná správa (cez getProperty): typ: $type, token: ${token != null ? 'present' : 'null'}, message: $errorMessage'); // DIAGNOSTIKA
                ref.read(authProvider.notifier).setLoginError('Prijatá neznáma správa pri prihlásení (cez getProperty).');
              }
           } else {
             print('AuthListenerInitializer: ERROR: Prijaté dáta nie sú JSObject ani Map po dartify: $rawData'); // DIAGNOSTIKA
             ref.read(authProvider.notifier).setLoginError('Neznáma chyba pri spracovaní prihlásenia (neznámy typ dát).');
           }
        }
      } catch (e, st) {
        print('AuthListenerInitializer: KRITICKÁ CHYBA pri spracovaní postMessage dát (hlavný catch): $e\n$st'); // DIAGNOSTIKA
        ref.read(authProvider.notifier).setLoginError('Kritická chyba pri spracovaní prihlásenia.');
      }
    }

    _messageListenerJsFn = dartCallback.toJS;
    web.window.addEventListener('message', _messageListenerJsFn);
  }

  @override
  void dispose() {
    print('AuthListenerInitializer: Odstraňujem listener.'); // DIAGNOSTIKA
    web.window.removeEventListener('message', _messageListenerJsFn);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}