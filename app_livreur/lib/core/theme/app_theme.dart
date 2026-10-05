import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Palette — App Livreur
// Primary : Vert forêt profond (forêt équatoriale gabonaise)
// Secondary : Or Kente (tissu traditionnel — partagé avec app client), réservé aux accents
class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static const Color primary = Color(0xFF0B5D4E);
  static const Color primaryDark = Color(0xFF084539);
  static const Color primarySoft = Color(0xFFE6F0ED);
  static const Color secondary = Color(0xFFE39A1C);
  static const Color secondarySoft = Color(0xFFFCF2DD);
  static const Color secondaryInk = Color(0xFF8A5A00);

  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Colors.white;
  static const Color line = Color(0xFFE4E9E7);

  static const Color ink = Color(0xFF101816);
  static const Color inkMuted = Color(0xFF5B6763);
  static const Color inkFaint = Color(0xFF94A09B);

  static const Color danger = Color(0xFFC7362B);
  static const Color dangerSoft = Color(0xFFFBEAE8);
  static const Color whatsapp = Color(0xFF1FAF54);

  static const double radius = 16;

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const buttonText = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: line,
          disabledForegroundColor: inkFaint,
          minimumSize: const Size(double.infinity, 54),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: line,
          disabledForegroundColor: inkFaint,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: line),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: inkFaint, fontWeight: FontWeight.w500),
        border: inputBorder(line),
        enabledBorder: inputBorder(line),
        focusedBorder: inputBorder(primary, 1.5),
        errorBorder: inputBorder(danger),
        focusedErrorBorder: inputBorder(danger, 1.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primarySoft,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? primary : inkFaint,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? primary : inkFaint,
          ),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: primary,
        inactiveTrackColor: line,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.1),
        trackHeight: 4,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: ink),
        contentTextStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, height: 1.45, color: inkMuted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }
}
