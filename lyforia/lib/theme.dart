import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF00BFA6);
  static const Color primaryVariant = Color(0xFF008E8A);
  static const Color secondary = Color(0xFFA6E22E);
  static const Color secondaryVariant = Color(0xFF7ACC3B);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1E2A32);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color disabledText = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF3BC9DB);
  static const Color error = Color(0xFFF87171);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Color(0xFFE0E0E0);
}

final _lightTextTheme = GoogleFonts.latoTextTheme(
  const TextTheme(
    bodyLarge: TextStyle(color: AppColors.primaryText),
    bodyMedium: TextStyle(color: AppColors.secondaryText),
  ),
);

final _darkTextTheme = GoogleFonts.latoTextTheme(
  const TextTheme(
    bodyLarge: TextStyle(color: AppColors.darkText),
    bodyMedium: TextStyle(color: AppColors.darkText),
  ),
);

final _inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: AppColors.disabledText),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: AppColors.disabledText),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: AppColors.primary),
  ),
  filled: true,
  fillColor: AppColors.surface,
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: _lightTextTheme,
  inputDecorationTheme: _inputDecorationTheme,
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    buttonColor: AppColors.primary,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: _darkTextTheme,
  inputDecorationTheme: _inputDecorationTheme.copyWith(
    fillColor: AppColors.darkBackground,
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkBackground,
    error: AppColors.error,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.darkText,
    onError: Colors.black,
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    buttonColor: AppColors.primary,
  ),
);