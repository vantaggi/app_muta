import 'package:flutter/material.dart';

// Enum per identificare facilmente il Cero
enum CeroType { santUbaldo, sanGiorgio, santAntonio }

class AppTheme {
  // Colori base
  static final Color _rosso = Colors.red.shade700;
  static const Color _bianco = Colors.white;

  // Temi specifici per ogni Cero
  static final ThemeData _santUbaldoTheme = ThemeData(
    primarySwatch: Colors.yellow,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.yellow,
      accentColor: _rosso,
      backgroundColor: _bianco,
      cardColor: Colors.yellow.shade50,
    ).copyWith(
      secondary: _rosso, // Colore secondario
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.yellow.shade700,
      foregroundColor: Colors.black, // Colore del testo nella AppBar
    ),
  );

  static final ThemeData _sanGiorgioTheme = ThemeData(
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      accentColor: _rosso,
      backgroundColor: _bianco,
      cardColor: Colors.blue.shade50,
    ).copyWith(
      secondary: _rosso,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData _santAntonioTheme = ThemeData(
    primarySwatch: Colors.grey,
    scaffoldBackgroundColor: const Color.fromARGB(255, 239, 239, 239),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Non c'è un swatch "nero"
      accentColor: _rosso,
      backgroundColor: _bianco,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.black, // Sovrascriviamo il primario con il nero
      secondary: _rosso,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  // Funzione per ottenere il tema corretto
  static ThemeData getTheme(CeroType ceroType, {bool isDarkMode = false}) {
    if (isDarkMode) {
      return _getDarkTheme(ceroType);
    }
    switch (ceroType) {
      case CeroType.santUbaldo:
        return _santUbaldoTheme;
      case CeroType.sanGiorgio:
        return _sanGiorgioTheme;
      case CeroType.santAntonio:
        return _santAntonioTheme;
      default:
        return _santUbaldoTheme; // Tema di default
    }
  }

  static ThemeData _getDarkTheme(CeroType ceroType) {
    switch (ceroType) {
      case CeroType.santUbaldo:
        return ThemeData.dark().copyWith(
          primaryColor: Colors.yellow.shade700,
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            primarySwatch: Colors.yellow,
            accentColor: _rosso,
          ).copyWith(
            secondary: _rosso,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.yellow.shade700,
            foregroundColor: Colors.black,
          ),
        );
      case CeroType.sanGiorgio:
        return ThemeData.dark().copyWith(
          primaryColor: Colors.blue.shade700,
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            accentColor: _rosso,
          ).copyWith(
            secondary: _rosso,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
        );
      case CeroType.santAntonio:
        return ThemeData.dark().copyWith(
          primaryColor: _rosso,
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            primarySwatch: Colors.grey,
            accentColor: _rosso,
          ).copyWith(
            primary: _rosso,
            secondary: _rosso,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        );
    }
  }
}