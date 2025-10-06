import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyforia/utils/app_constants.dart';

class AppColors {
  static const Color seed = Color(0xFF4F46E5);
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
}

final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.seed,
  brightness: Brightness.light,
  background: AppColors.lightBackground,
  surface: AppColors.lightSurface,
);

final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.seed,
  brightness: Brightness.dark,
  background: AppColors.darkBackground,
  surface: AppColors.darkSurface,
);

TextTheme _buildTextTheme(Brightness brightness, Color foregroundColor) {
  final base = ThemeData(brightness: brightness).textTheme;
  return GoogleFonts.latoTextTheme(base).apply(
    bodyColor: foregroundColor,
    displayColor: foregroundColor,
  );
}

InputDecorationTheme _buildInputDecorationTheme(ColorScheme scheme) {
  final subtle = scheme.onSurface.withOpacity(0.6);
  return InputDecorationTheme(
    filled: true,
    fillColor: scheme.surface,
    floatingLabelStyle: TextStyle(color: scheme.primary),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    labelStyle: TextStyle(color: subtle),
    hintStyle: TextStyle(color: subtle),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: scheme.outline.withOpacity(0.4)),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: scheme.outline.withOpacity(0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: scheme.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: scheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: scheme.error),
    ),
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme scheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    ),
  );
}

ThemeData _buildTheme(ColorScheme scheme, TextTheme textTheme) {
  final onSurfaceVariant = scheme.onSurfaceVariant;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    primaryColor: scheme.primary,
    scaffoldBackgroundColor: scheme.background,
    textTheme: textTheme,
    inputDecorationTheme: _buildInputDecorationTheme(scheme),
    elevatedButtonTheme: _buildElevatedButtonTheme(scheme),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      elevation: AppSizes.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return scheme.primary;
        }
        return onSurfaceVariant.withOpacity(0.6);
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return scheme.primary;
        }
        return onSurfaceVariant.withOpacity(0.7);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return scheme.primary.withOpacity(0.45);
        }
        return onSurfaceVariant.withOpacity(0.2);
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.primary.withOpacity(0.2),
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withOpacity(0.1),
      valueIndicatorColor: scheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: AppSizes.elevationLow,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: onSurfaceVariant,
      selectedIconTheme: IconThemeData(color: scheme.primary),
      unselectedIconTheme: IconThemeData(color: onSurfaceVariant),
      showUnselectedLabels: true,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: scheme.onSurface),
  );
}

final TextTheme _lightTextTheme =
    _buildTextTheme(Brightness.light, _lightColorScheme.onBackground);
final TextTheme _darkTextTheme =
    _buildTextTheme(Brightness.dark, _darkColorScheme.onBackground);

final ThemeData lightTheme = _buildTheme(_lightColorScheme, _lightTextTheme);
final ThemeData darkTheme = _buildTheme(_darkColorScheme, _darkTextTheme);
