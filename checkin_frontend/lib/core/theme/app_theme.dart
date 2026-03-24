import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = (state == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class AppTheme {
  static const blueLineColor = Color(0xFF448AFF);
  static const Color myLightBlueBg = Color.fromRGBO(240, 244, 248, 1);
  static const Color myLightBorder = Color.fromRGBO(204, 223, 255, 1);
  static const Color myAccentBlue = Colors.blueAccent;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: myAccentBlue,
        surface: Colors.white, // Hlavné pozadie (Scaffold)
        surfaceContainer: myLightBlueBg, // Pozadie tvojich Boxov/Kariet (M3 slot)
        outlineVariant: myLightBorder, // Jemné čiary/bordery
        primary: myAccentBlue, // Hlavná modrá
        onSurface: Colors.black87, // Hlavný text
        onSurfaceVariant: Colors.black54, // Vedľajší text (poznámky)
      ),
      cardTheme: CardThemeData(
        color: myLightBlueBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: myLightBorder, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF121212), // Skoro čierna (OLED friendly)
        surfaceContainer: Color(0xFF1E1E1E), // Tmavosivá pre kontajnery
        outlineVariant: Color(0xFF333333), // Tmavé bordery
        primary: Colors.blueAccent, // Modrá zostáva ako accent
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E), // Tmavá pre karty
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blueAccent.withOpacity(0.3), width: 2),
        ),
      ),
    );
  }
}
