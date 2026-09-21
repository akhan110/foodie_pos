import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand and semantic colors.
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFFF6338);
  static const Color success = Color(0xFF12B76A);
  static const Color error = Color(0xFFF04438);
  static const Color warning = Color(0xFFF79009);
  static const Color successSurface = Color(0xFFEAF8EF);
  static const Color errorSurface = Color(0xFFFDECEC);

  // Light theme.
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightCart = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF4F6F8);
  static const Color lightTextPrimary = Color(0xFF1D2939);
  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color lightBorder = Color(0xFFE4E7EC);
  static const Color lightIcon = Color(0xFF667085);
  static const Color lightInputBackground = Color(0xFFF4F6F8);

  // Dark theme.
  static const Color darkBackground = Color(0xFF0B1523);
  static const Color darkSidebar = Color(0xFF111E2E);
  static const Color darkCart = Color(0xFF162334);
  static const Color darkSurface = Color(0xFF1C2A3C);
  static const Color darkTextPrimary = Color(0xFFF5F7FA);
  static const Color darkTextSecondary = Color(0xFF98A2B3);
  static const Color darkBorder = Color(0xFF29384B);
  static const Color darkIcon = Color(0xFF98A2B3);
  static const Color darkInputBackground = Color(0xFF222A35);

  static Color sidebar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSidebar
        : lightSidebar;
  }

  static Color cart(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCart
        : lightCart;
  }
}
