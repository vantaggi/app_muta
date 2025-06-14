import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_muta/screens/main_navigator.dart';
import 'package:app_muta/theme/theme_provider.dart';

void main() {
  runApp(const AppMuta());
}

class AppMuta extends StatelessWidget {
  const AppMuta({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'App Muta',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,
            home: const MainNavigator(),
          );
        },
      ),
    );
  }
}