import 'package:flutter/material.dart';
import 'package:muta_manager/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  CeroType _currentCero = CeroType.santUbaldo; // Cero di default
  bool _isDarkMode = false;

  CeroType get currentCero => _currentCero;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => AppTheme.getTheme(_currentCero, isDarkMode: _isDarkMode);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  String get currentCeroName {
    switch (_currentCero) {
      case CeroType.santUbaldo:
        return "Sant'Ubaldo";
      case CeroType.sanGiorgio:
        return "San Giorgio";
      case CeroType.santAntonio:
        return "Sant'Antonio";
    }
  }

  // Cambia il cero e notifica tutti i listener
  void changeCero(CeroType newCero) {
    if (_currentCero != newCero) {
      _currentCero = newCero;
      notifyListeners();
    }
  }

  // Metodo per ciclare tra i ceri (utile per test)
  void cycleCero() {
    switch (_currentCero) {
      case CeroType.santUbaldo:
        changeCero(CeroType.sanGiorgio);
        break;
      case CeroType.sanGiorgio:
        changeCero(CeroType.santAntonio);
        break;
      case CeroType.santAntonio:
        changeCero(CeroType.santUbaldo);
        break;
    }
  }

  // Ottieni l'icona rappresentativa del cero
  IconData get currentCeroIcon {
    switch (_currentCero) {
      case CeroType.santUbaldo:
        return Icons.star; // Simbolo per Sant'Ubaldo
      case CeroType.sanGiorgio:
        return Icons.shield; // Simbolo per San Giorgio
      case CeroType.santAntonio:
        return Icons.local_fire_department; // Simbolo per Sant'Antonio
    }
  }

  // Ottieni il colore primario del cero corrente
  Color get currentPrimaryColor {
    switch (_currentCero) {
      case CeroType.santUbaldo:
        return Colors.yellow.shade700;
      case CeroType.sanGiorgio:
        return Colors.blue.shade700;
      case CeroType.santAntonio:
        return Colors.black;
    }
  }
}