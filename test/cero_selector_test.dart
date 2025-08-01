import 'package:muta_manager/theme/app_theme.dart';
import 'package:muta_manager/theme/theme_provider.dart';
import 'package:muta_manager/widgets/cero_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('CeroSelector Widget Tests', () {
    testWidgets('Tapping a Cero changes the theme', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: MaterialApp(
            home: Scaffold(
              body: CeroSelector(onCeroChanged: (_) {}),
            ),
          ),
        ),
      );

      // Initial state is Sant'Ubaldo
      expect(themeProvider.currentCero, CeroType.santUbaldo);

      // Find the San Giorgio Cero and tap it
      await tester.tap(find.byIcon(Icons.shield));
      await tester.pumpAndSettle();

      // Verify the theme has changed
      expect(themeProvider.currentCero, CeroType.sanGiorgio);

      // Find the Sant'Antonio Cero and tap it
      await tester.tap(find.byIcon(Icons.local_fire_department));
      await tester.pumpAndSettle();

      // Verify the theme has changed again
      expect(themeProvider.currentCero, CeroType.santAntonio);
    });
  });
}
