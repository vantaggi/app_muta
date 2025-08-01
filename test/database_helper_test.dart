import 'package:app_muta/models/ceraiolo_model.dart';
import 'package:app_muta/models/muta_model.dart';
import 'package:app_muta/services/database_helper.dart';
import 'package:app_muta/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();

  // Use an in-memory database for testing
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Make sure we have a clean database for each test
      await dbHelper.database;
      await dbHelper.close();
      await deleteDatabase(await getDatabasesPath() + '/muta.db');
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      await dbHelper.close();
    });

    group('Ceraioli CRUD', () {
      test('Insert and Read Ceraiolo', () async {
        final ceraiolo = Ceraiolo(id: '1', nome: 'Mario', cognome: 'Rossi');
        await dbHelper.insertCeraiolo(ceraiolo);

        final readCeraiolo = await dbHelper.readCeraiolo('1');
        expect(readCeraiolo.nome, 'Mario');
        expect(readCeraiolo.cognome, 'Rossi');
      });

      test('Read All Ceraioli', () async {
        await dbHelper.insertCeraiolo(Ceraiolo(id: '1', nome: 'Mario', cognome: 'Rossi'));
        await dbHelper.insertCeraiolo(Ceraiolo(id: '2', nome: 'Luigi', cognome: 'Verdi'));

        final ceraioli = await dbHelper.readAllCeraioli();
        expect(ceraioli.length, 2);
        // They should be ordered by cognome
        expect(ceraioli[0].cognome, 'Rossi');
        expect(ceraioli[1].cognome, 'Verdi');
      });

      test('Update Ceraiolo', () async {
        final ceraiolo = Ceraiolo(id: '1', nome: 'Mario', cognome: 'Rossi');
        await dbHelper.insertCeraiolo(ceraiolo);

        final updatedCeraiolo = Ceraiolo(id: '1', nome: 'Mario', cognome: 'Bianchi');
        await dbHelper.updateCeraiolo(updatedCeraiolo);

        final readCeraiolo = await dbHelper.readCeraiolo('1');
        expect(readCeraiolo.cognome, 'Bianchi');
      });

      test('Delete Ceraiolo', () async {
        final ceraiolo = Ceraiolo(id: '1', nome: 'Mario', cognome: 'Rossi');
        await dbHelper.insertCeraiolo(ceraiolo);

        await dbHelper.deleteCeraiolo('1');

        expect(dbHelper.readCeraiolo('1'), throwsA(isA<Exception>()));
      });

      test('Search Ceraioli', () async {
        await dbHelper.insertCeraiolo(Ceraiolo(id: '1', nome: 'Mario', cognome: 'Rossi'));
        await dbHelper.insertCeraiolo(Ceraiolo(id: '2', nome: 'Luigi', cognome: 'Verdi', soprannome: 'Gigi'));
        await dbHelper.insertCeraiolo(Ceraiolo(id: '3', nome: 'Maria', cognome: 'Neri'));

        final results = await dbHelper.searchCeraioli('mar');
        expect(results.length, 2);
        expect(results[0].nome, 'Maria');
        expect(results[1].nome, 'Mario');

        final results2 = await dbHelper.searchCeraioli('Gigi');
        expect(results2.length, 1);
        expect(results2[0].nome, 'Luigi');
      });
    });

    group('Mute Search', () {
      // Helper to create a dummy muta
      Muta _createDummyMuta({
        required String id,
        required int anno,
        required CeroType cero,
        required List<PersonaMuta> persone,
      }) {
        return Muta(
          id: id,
          anno: anno,
          cero: cero,
          nomeMuta: 'Test Muta $id',
          posizione: 'Test Posizione',
          dataCreazione: DateTime.now(),
          stangaSinistra: persone.where((p) => persone.indexOf(p) < 4).toList(),
          stangaDestra: persone.where((p) => persone.indexOf(p) >= 4).toList(),
        );
      }

      PersonaMuta _createDummyPersona(String nome, String cognome, {String? soprannome}) {
        return PersonaMuta(
          nome: nome,
          cognome: cognome,
          soprannome: soprannome,
          ruolo: RuoloMuta.puntaAvanti,
        );
      }

      test('Read Mute by Year and Cero', () async {
        final persona1 = _createDummyPersona('Paolo', 'Azzurri');
        final muta1 = _createDummyMuta(id: 'm1', anno: 2023, cero: CeroType.santUbaldo, persone: [persona1]);
        await dbHelper.insertMuta(muta1);

        final persona2 = _createDummyPersona('Marco', 'Gialli');
        final muta2 = _createDummyMuta(id: 'm2', anno: 2023, cero: CeroType.sanGiorgio, persone: [persona2]);
        await dbHelper.insertMuta(muta2);

        final persona3 = _createDummyPersona('Luca', 'Neri');
        final muta3 = _createDummyMuta(id: 'm3', anno: 2024, cero: CeroType.santUbaldo, persone: [persona3]);
        await dbHelper.insertMuta(muta3);

        final results = await dbHelper.readMuteByYearAndCero(2023, CeroType.santUbaldo);
        expect(results.length, 1);
        expect(results[0].id, 'm1');
      });

      test('Search Mute by Person', () async {
        final persona1 = _createDummyPersona('Giovanni', 'Bianchi');
        final muta1 = _createDummyMuta(id: 'm1', anno: 2023, cero: CeroType.santUbaldo, persone: [persona1]);
        await dbHelper.insertMuta(muta1);

        final persona2 = _createDummyPersona('Giovanni', 'Verdi', soprannome: 'Gio');
        final muta2 = _createDummyMuta(id: 'm2', anno: 2023, cero: CeroType.sanGiorgio, persone: [persona2]);
        await dbHelper.insertMuta(muta2);

        final results = await dbHelper.searchMuteByPerson('Giovanni');
        expect(results.length, 2);

        final results2 = await dbHelper.searchMuteByPerson('Bianchi');
        expect(results2.length, 1);
        expect(results2[0].id, 'm1');

        final results3 = await dbHelper.searchMuteByPerson('Gio');
        expect(results3.length, 1);
        expect(results3[0].id, 'm2');
      });
    });
  });
}
