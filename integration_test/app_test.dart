import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:muta_manager/main.dart' as app;
import 'package:provider/provider.dart';
import 'package:muta_manager/theme/theme_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('create and verify muta in archive', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. Skip login
      await tester.tap(find.text('Continua come ospite'));
      await tester.pumpAndSettle();

      // We should be on the main navigator now.
      // Let's verify by looking for the home screen title.
      expect(find.text("App Muta - Sant'Ubaldo"), findsOneWidget);

      // 2. Navigate to the "Crea" tab.
      // The tabs are in the MainNavigator's BottomNavigationBar.
      // The "Crea" tab should have the "Add" icon.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // We are now on the CreateMutaScreen.
      // Let's fill the form.
      final mutaName = 'Muta di Integrazione';
      await tester.enterText(find.byType(TextFormField).at(0), mutaName);
      await tester.enterText(find.byType(TextFormField).at(1), 'Via dei Matti');
      await tester.enterText(find.byType(TextFormField).at(2), '2024');

      // Go to the next step (Stanga Sinistra)
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Fill in one person for simplicity
      await tester.enterText(find.byType(TextFormField).at(0), 'Mario');
      await tester.enterText(find.byType(TextFormField).at(1), 'Rossi');

      // Go to the next step (Stanga Destra)
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Fill in one person for simplicity
      await tester.enterText(find.byType(TextFormField).at(0), 'Luigi');
      await tester.enterText(find.byType(TextFormField).at(1), 'Verdi');

      // Go to the last step (Note & Salva)
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // 3. Save the muta
      await tester.tap(find.text('Salva Muta'));
      await tester.pumpAndSettle();

      // A snackbar should appear
      expect(find.text('Muta "$mutaName" salvata con successo!'), findsOneWidget);

      // 4. Navigate to the "Archivio" tab.
      await tester.tap(find.byIcon(Icons.archive));
      await tester.pumpAndSettle();

      // 5. Verify the new muta is in the archive list.
      // We need to select the year 2024 first.
      await tester.tap(find.text('Seleziona Anno'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2024'));
      await tester.pumpAndSettle();

      // Now the muta should be visible.
      expect(find.text(mutaName), findsOneWidget);
    });
  });
}
