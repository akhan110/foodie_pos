import 'package:flutter/material.dart';
import 'package:foodiepos/app/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.lightSurface,
          surfaceContainerLow: AppColors.lightCart,
          surfaceContainerHighest: AppColors.lightSurfaceSecondary,
          onSurface: AppColors.lightTextPrimary,
          onSurfaceVariant: AppColors.lightTextSecondary,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightBorder,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightIcon),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBackground,
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        prefixIconColor: AppColors.lightIcon,
        suffixIconColor: AppColors.lightIcon,
        border: _inputBorder(AppColors.lightBorder),
        enabledBorder: _inputBorder(AppColors.lightBorder),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.5),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primaryDark,
          onPrimary: Colors.white,
          surface: AppColors.darkSurface,
          surfaceContainerLow: AppColors.darkCart,
          surfaceContainerHighest: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorder,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkIcon),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
        prefixIconColor: AppColors.darkIcon,
        suffixIconColor: AppColors.darkIcon,
        border: _inputBorder(AppColors.darkBorder),
        enabledBorder: _inputBorder(AppColors.darkBorder),
        focusedBorder: _inputBorder(AppColors.primaryDark, width: 1.5),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
