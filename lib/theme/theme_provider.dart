import 'package:flutter/material.dart';
import 'package:muta_manager/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  CeroType _currentCero = CeroType.santUbaldo; // Default Cero
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

  void changeCero(CeroType newCero) {
    if (_currentCero != newCero) {
      _currentCero = newCero;
      notifyListeners();
    }
  }

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

  IconData get currentCeroIcon {
    switch (_currentCero) {
      case CeroType.santUbaldo:
        return Icons.star;
      case CeroType.sanGiorgio:
        return Icons.shield;
      case CeroType.santAntonio:
        return Icons.local_fire_department;
    }
  }

  Color get currentPrimaryColor {
    return AppTheme.getPrimaryColor(_currentCero);
  }
}
