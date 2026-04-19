import 'package:flutter/material.dart';

class AppTheme {
  static const _background = Color(0xFF07111A);
  static const _surface = Color(0xFF0C1622);
  static const _surfaceAlt = Color(0xFF17354A);
  static const _primary = Color(0xFF79E7FF);
  static const _secondary = Color(0xFF25F3B4);
  static const _text = Color(0xFFF3FBFF);
  static const _muted = Color(0xFF98A9B5);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        surface: _surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _text,
        displayColor: _text,
      ),
      dividerColor: _surfaceAlt,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _surfaceAlt),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: _surfaceAlt,
        selectedColor: _primary.withValues(alpha: 0.16),
        labelStyle: const TextStyle(color: _text),
        side: const BorderSide(color: Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _secondary,
        unselectedItemColor: _muted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
