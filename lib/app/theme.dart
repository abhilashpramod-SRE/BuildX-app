import 'package:flutter/material.dart';

class BuildXTheme {
  static const Color navy = Color(0xFF0D1B2A);
  static const Color orange = Color(0xFFF77F00);
  static const Color offWhite = Color(0xFFF8F9FA);

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        secondary: orange,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: offWhite,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
