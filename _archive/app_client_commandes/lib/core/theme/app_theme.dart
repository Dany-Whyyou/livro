import 'package:flutter/material.dart';

// Palette africaine — App Client
// Primary : Orange brûlé (coucher de soleil du Gabon)
// Secondary : Or Kente (tissu traditionnel)
class AppTheme {
  static const Color primary = Color(0xFFE65100);
  static const Color secondary = Color(0xFFF4A228);
  static const Color background = Color(0xFFFFF8F5);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          secondary: secondary,
          surface: background,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: primary.withValues(alpha: 0.12),
        ),
      );
}
