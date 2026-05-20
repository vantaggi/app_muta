import 'package:flutter/material.dart';

enum CeroType { santUbaldo, sanGiorgio, santAntonio }

class AppTheme {
  // Brand Colors
  static const Color ubaldoPrimary = Color(0xFFD4AC0D); // Deep Yellow/Gold
  static const Color giorgioPrimary = Color(0xFF2980B9); // Rich Blue
  static const Color antonioPrimary = Color(0xFF1E1E24); // Black/Charcoal

  static const Color accentRed = Color(0xFFC0392B); // Crimson Red (fazzoletto)

  // Background Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);

  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Spacing Constants
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;

  // Border Radii Constants
  static final BorderRadius macroBorderRadius = BorderRadius.circular(16.0);
  static final BorderRadius microBorderRadius = BorderRadius.circular(12.0);

  // Typography
  static TextTheme _buildTextTheme(Color textColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        color: secondaryTextColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.25,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        color: secondaryTextColor,
      ),
    );
  }

  // Component Themes
  static CardThemeData _buildCardTheme(Color surfaceColor) {
    return CardThemeData(
      color: surfaceColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: spacingSm, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: macroBorderRadius,
      ),
      // Handled via external shadow in actual widgets as CardTheme doesn't natively support highly customized diffuse shadows well
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Color primaryColor, bool isDark) {
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final fillColor = isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(5); // 0.05 opacity = 13 alpha, 0.02 opacity = 5 alpha

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: spacingMd, vertical: spacingMd),
      border: OutlineInputBorder(
        borderRadius: microBorderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: microBorderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: microBorderRadius,
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: microBorderRadius,
        borderSide: const BorderSide(color: accentRed, width: 2),
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
        shape: RoundedRectangleBorder(
          borderRadius: microBorderRadius,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Shadows
  static List<BoxShadow> get ambientShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(10), // 0.04 opacity = 10 alpha
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static Color getPrimaryColor(CeroType type) {
    switch (type) {
      case CeroType.santUbaldo:
        return ubaldoPrimary;
      case CeroType.sanGiorgio:
        return giorgioPrimary;
      case CeroType.santAntonio:
        return antonioPrimary;
    }
  }

  static ThemeData getTheme(CeroType ceroType, {bool isDarkMode = false}) {
    final Color primaryColor = getPrimaryColor(ceroType);
    final Color backgroundColor = isDarkMode ? darkBackground : lightBackground;
    final Color surfaceColor = isDarkMode ? darkSurface : lightSurface;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: accentRed,
        surface: surfaceColor,
        error: accentRed,
      ),
      textTheme: _buildTextTheme(textColor, secondaryTextColor),
      cardTheme: _buildCardTheme(surfaceColor),
      inputDecorationTheme: _buildInputDecorationTheme(primaryColor, isDarkMode),
      elevatedButtonTheme: _buildElevatedButtonTheme(primaryColor),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: microBorderRadius,
        ),
      ),
    );
  }
}
