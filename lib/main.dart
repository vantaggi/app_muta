import 'package:flutter/material.dart';
import 'package:app_muta/screens/main_navigator.dart'; // Creeremo questo file tra poco
import 'package:app_muta/theme/app_theme.dart';

void main() {
  runApp(const AppMuta());
}

class AppMuta extends StatelessWidget {
  const AppMuta({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Muta',
      // Definiamo un tema di partenza (es. Sant'Ubaldo)
      // In futuro questo potrà cambiare dinamicamente
      theme: AppTheme.getTheme(CeroType.santUbaldo),
      debugShowCheckedModeBanner: false,
      home: const MainNavigator(),
    );
  }
}