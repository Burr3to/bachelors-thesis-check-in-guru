import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleNotifier extends Notifier<Locale> {
  final _storage = const FlutterSecureStorage();

  @override
  Locale build() {
    // Tu môžeš skúsiť načítať uložený jazyk, ale build musí byť synchrónny,
    // takže ideálne vráť default a potom asynchrónne načítaj v initState appky.
    return const Locale('en');
  }

  Future<void> setLocale(Locale l) async {
    state = l;
    await _storage.write(key: 'selected_language', value: l.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);