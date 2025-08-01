import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muta_manager/screens/login_screen.dart';
import 'package:muta_manager/theme/theme_provider.dart';

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
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}