import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Notifier that manages the application's current language (Locale).
/// Logic for persistence is kept for future use, but English is enforced as default.
class LocaleNotifier extends Notifier<Locale> {
  final _storage = const FlutterSecureStorage();

  @override
  Locale build() {
    return const Locale('en', 'US');
  }

  /// Updates the application language.
  /// Hardcoded to English for current version consistency.
  Future<void> setLocale(Locale l) async {
    // state = l;

    state = const Locale('en', 'US');
    await _storage.write(key: 'selected_language', value: 'en');
  }
}

/// Global provider for managing and accessing the app's localization state.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);