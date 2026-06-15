import 'package:flutter/material.dart';

/// 1SocialSuite brand theme — black & gold. LOCKED palette.
/// Gold #FFB800 on near-black, matching the orbiting-1 logo.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceAlt = Color(0xFF1A1A1A);
  static const Color gold = Color(0xFFFFB800);
  static const Color goldDeep = Color(0xFFE89611);
  static const Color goldGlow = Color(0xFFFFD166);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color border = Color(0x33FFB800); // gold @ 20%
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldDeep,
        surface: AppColors.surface,
        onPrimary: AppColors.black,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
