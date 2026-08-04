import 'package:flutter/material.dart';

/// Brown palette lifted 1:1 from style.css's CSS custom properties, so the
/// app reads as the same brand as the web site.
class AppColors {
  static const brown900 = Color(0xFF3B2418);
  static const brown800 = Color(0xFF4E2F1F);
  static const brown700 = Color(0xFF6B4226);
  static const brown600 = Color(0xFF8A5A35);
  static const brown500 = Color(0xFFA8703F);
  static const brown400 = Color(0xFFC1885A);
  static const brown300 = Color(0xFFD9AB84);
  static const brown200 = Color(0xFFECD2B8);
  static const brown100 = Color(0xFFF6E6D3);

  static const accent = brown500;

  // Light mode
  static const bg0Light = Color(0xFFF6F0E8);
  static const bg1Light = Color(0xFFEFE2D0);
  static const bg2Light = Color(0xFFE6D3BA);
  static const text0Light = Color(0xFF2A1A10);
  static const text1Light = Color(0xFF4A3524);
  static const textMutedLight = Color(0xFF7C6552);

  // Dark mode
  static const bg0Dark = Color(0xFF17110D);
  static const bg1Dark = Color(0xFF1C140E);
  static const bg2Dark = Color(0xFF241A12);
  static const text0Dark = Color(0xFFF5E8D9);
  static const text1Dark = Color(0xFFE4CFB8);
  static const textMutedDark = Color(0xFFA88F78);
}

class AppTheme {
  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg0 = isDark ? AppColors.bg0Dark : AppColors.bg0Light;
    final bg1 = isDark ? AppColors.bg1Dark : AppColors.bg1Light;
    final text0 = isDark ? AppColors.text0Dark : AppColors.text0Light;
    final text1 = isDark ? AppColors.text1Dark : AppColors.text1Light;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final base = ColorScheme(
      brightness: brightness,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.brown700,
      onSecondary: Colors.white,
      surface: bg1,
      onSurface: text0,
      error: const Color(0xFFC0503F),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: base,
      scaffoldBackgroundColor: bg0,
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: bg0,
        foregroundColor: text0,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: text1,
            displayColor: text0,
          ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.brown900.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text0,
          side: BorderSide(color: textMuted.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bg1,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: textMuted,
      ),
      dividerColor: textMuted.withValues(alpha: 0.15),
    );
  }
}
