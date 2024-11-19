// lib/config/theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF00357B);
  static const Color primaryVariantLight = Color(0xFF6EA4EA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLight = Color(0xFFF5F5F5);
  static const Color surfaceContainerHighLight = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighestLight = Color(0xFFEBF3FF);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF6EA4EA);
  static const Color primaryVariantDark = Color(0xFF00357B);
  static const Color surfaceDark = Color(0xFF001F3F);
  static const Color surfaceContainerDark = Color(0xFF0A2744);
  static const Color surfaceContainerHighDark = Color(0xFF173454);
  static const Color surfaceContainerHighestDark = Color(0xFF264B73);

  // Common Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF0000);
  static const Color warning = Color(0xFFFFA500);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.primaryVariantLight,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: Colors.black,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      tertiary: AppColors.primaryVariantLight,
      onTertiary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.surfaceLight,
    cardTheme: CardTheme(
      color: AppColors.surfaceContainerHighLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.primaryLight,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.primaryLight,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.primaryVariantDark,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: Colors.white,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      tertiary: AppColors.primaryVariantDark,
      onTertiary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.surfaceDark,
    cardTheme: CardTheme(
      color: AppColors.surfaceContainerHighDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
  );
}
