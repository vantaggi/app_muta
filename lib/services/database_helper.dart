import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_muta/models/muta_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('muta.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const realType = 'REAL';

    await db.execute('''
CREATE TABLE mute (
  id $idType,
  cero $intType,
  nomeMuta $textType,
  posizione $textType,
  latitude $realType,
  longitude $realType,
  dataCreazione $textType,
  dataModifica $textType,
  anno $intType,
  note $textType,
  verificata $boolType,
  numeroVerifiche $intType
  )
''');

    await db.execute('''
CREATE TABLE persone (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mutaId $textType,
  isSinistra $boolType,
  nome $textType,
  cognome $textType,
  soprannome $textType,
  ruolo $intType,
  note $textType,
  FOREIGN KEY (mutaId) REFERENCES mute (id) ON DELETE CASCADE
)
''');
  }

  Future<void> insertMuta(Muta muta) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('mute', muta.toJson()..remove('stangaSinistra')..remove('stangaDestra'));
      for (var persona in muta.stangaSinistra) {
        await txn.insert('persone', persona.toJson()..['mutaId'] = muta.id..['isSinistra'] = true);
      }
      for (var persona in muta.stangaDestra) {
        await txn.insert('persone', persona.toJson()..['mutaId'] = muta.id..['isSinistra'] = false);
      }
    });
  }

  Future<Muta> readMuta(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'mute',
      columns: ['id', 'cero', 'nomeMuta', 'posizione', 'latitude', 'longitude', 'dataCreazione', 'dataModifica', 'anno', 'note', 'verificata', 'numeroVerifiche'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final mutaMap = maps.first;
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [id]);
      final stangaSinistra = personeMaps.where((p) => p['isSinistra'] == 1).map((p) => PersonaMuta.fromJson(p)).toList();
      final stangaDestra = personeMaps.where((p) => p['isSinistra'] == 0).map((p) => PersonaMuta.fromJson(p)).toList();

      return Muta.fromJson({
        ...mutaMap,
        'stangaSinistra': stangaSinistra,
        'stangaDestra': stangaDestra,
      });
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Muta>> readAllMute() async {
    final db = await instance.database;
    final result = await db.query('mute');
    final muteList = <Muta>[];
    for (var mutaMap in result) {
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [mutaMap['id']]);
      final stangaSinistra = personeMaps.where((p) => p['isSinistra'] == 1).map((p) => PersonaMuta.fromJson(p)).toList();
      final stangaDestra = personeMaps.where((p) => p['isSinistra'] == 0).map((p) => PersonaMuta.fromJson(p)).toList();

      muteList.add(Muta.fromJson({
        ...mutaMap,
        'stangaSinistra': stangaSinistra,
        'stangaDestra': stangaDestra,
      }));
    }
    return muteList;
  }

  Future<int> updateMuta(Muta muta) async {
    final db = await instance.database;
    return db.update(
      'mute',
      muta.toJson(),
      where: 'id = ?',
      whereArgs: [muta.id],
    );
  }

  Future<int> deleteMuta(String id) async {
    final db = await instance.database;
    return await db.delete(
      'mute',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
