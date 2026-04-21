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
  static const Color myLightBorder = Color.fromRGBO(147, 184, 248, 1.0);
  static const Color myAccentBlue = Colors.blueAccent;

  static const Color quillLightEditorBg = Color.fromRGBO(100, 130, 255, 0.1);
  static const Color quillLightToolbarBg = Color(0xFFF5F5F5);
  static const Color quillLightBorder = Color.fromRGBO(81, 119, 200, 0.5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: myAccentBlue, // Farba blikajúcej paličky
        selectionColor: myAccentBlue.withAlpha(75), // Farba podfarbenia textu pri výbere
        selectionHandleColor: myAccentBlue, // Farba bublín na konci výberu
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: myAccentBlue,
        surface: Colors.white, // Hlavné pozadie (Scaffold)
        surfaceContainer: myLightBlueBg, // Pozadie tvojich Boxov/Kariet (M3 slot)
        surfaceContainerHigh: quillLightToolbarBg, // Použijeme tento slot pre toolbar
        surfaceContainerLow: quillLightEditorBg,  // Použijeme tento slot pre editor
        outline: quillLightBorder,               // Pôvodný border
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
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.blueAccent,
        selectionColor: Color.fromRGBO(68, 138, 255, 0.4),
        selectionHandleColor: Colors.blueAccent,
      ),
      colorScheme: ColorScheme.dark(
        surface: const Color(0xFF121212), // Skoro čierna (OLED friendly)
        surfaceContainer: const Color(0xFF1E1E1E), // Tmavosivá pre kontajnery
        surfaceContainerHigh: const Color(0xFF252525), // Toolbar v dark
        surfaceContainerLow: const Color(0xFF1A1A1A),  // Editor v dark
        outline: Colors.blueAccent.withAlpha(75),   // Jemnejší border v dark
        outlineVariant: const Color(0xFF333333), // Tmavé bordery
        primary: Colors.blueAccent, // Modrá zostáva ako accent
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E), // Tmavá pre karty
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blueAccent.withAlpha(75), width: 2),
        ),
      ),
    );
  }
}
