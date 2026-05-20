import 'package:flutter/foundation.dart';
import 'package:muta_manager/models/ceraiolo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:muta_manager/models/muta_model.dart';
import 'package:muta_manager/theme/app_theme.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static final DatabaseHelper instance = _instance ??= DatabaseHelper._init();
  static Database? _database;

  // Web-only in-memory storage fallback with sample data
  static final List<Muta> _webMute = [
    Muta.validateAndCreate(
      id: 'm1',
      cero: CeroType.santUbaldo,
      nomeMuta: 'Calata dei Neri',
      posizione: 'Calata dei Neri',
      latitude: 43.3524,
      longitude: 12.5786,
      stangaSinistra: [
        PersonaMuta(nome: 'Roberto', cognome: 'Rossi', soprannome: 'Bebbo', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Francesco', cognome: 'Bianchi', soprannome: 'Checco', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Lorenzo', cognome: 'Verdi', soprannome: 'Lollo', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Giovanni', cognome: 'Neri', soprannome: 'Gianni', ruolo: RuoloMuta.puntaDietro),
      ],
      stangaDestra: [
        PersonaMuta(nome: 'Pietro', cognome: 'Gialli', soprannome: 'Piero', ruolo: RuoloMuta.puntaAvanti),
        PersonaMuta(nome: 'Giacomo', cognome: 'Marroni', soprannome: 'Jack', ruolo: RuoloMuta.ceppoAvanti),
        PersonaMuta(nome: 'Filippo', cognome: 'Grigi', soprannome: 'Fil', ruolo: RuoloMuta.ceppoDietro),
        PersonaMuta(nome: 'Matteo', cognome: 'Azzurri', soprannome: 'Matt', ruolo: RuoloMuta.puntaDietro),
      ],
      dataCreazione: DateTime.now(),
      anno: 2026,
      note: 'Muta storica della Calata dei Neri',
      verificata: true,
      numeroVerifiche: 3,
    )
  ];

  static final List<Ceraiolo> _webCeraioli = [
    Ceraiolo(id: 'c1', nome: 'Roberto', cognome: 'Rossi', soprannome: 'Bebbo', cero: CeroType.santUbaldo),
    Ceraiolo(id: 'c2', nome: 'Francesco', cognome: 'Bianchi', soprannome: 'Checco', cero: CeroType.santUbaldo),
    Ceraiolo(id: 'c3', nome: 'Lorenzo', cognome: 'Verdi', soprannome: 'Lollo', cero: CeroType.santUbaldo),
    Ceraiolo(id: 'c4', nome: 'Giovanni', cognome: 'Neri', soprannome: 'Gianni', cero: CeroType.santUbaldo),
    Ceraiolo(id: 'c5', nome: 'Michele', cognome: 'Fiorucci', soprannome: 'Miki', cero: CeroType.sanGiorgio),
    Ceraiolo(id: 'c6', nome: 'Andrea', cognome: 'Uccellani', soprannome: 'Kino', cero: CeroType.sanGiorgio),
    Ceraiolo(id: 'c7', nome: 'Filippo', cognome: 'Gini', soprannome: 'Pippo', cero: CeroType.sanGiorgio),
    Ceraiolo(id: 'c8', nome: 'Matteo', cognome: 'Bazzurri', soprannome: 'Teo', cero: CeroType.sanGiorgio),
    Ceraiolo(id: 'c9', nome: 'Giuseppe', cognome: 'Radicchi', soprannome: 'Peppe', cero: CeroType.santAntonio),
    Ceraiolo(id: 'c10', nome: 'Claudio', cognome: 'Sannipoli', soprannome: 'Icio', cero: CeroType.santAntonio),
    Ceraiolo(id: 'c11', nome: 'Marco', cognome: 'Minelli', soprannome: 'Killa', cero: CeroType.santAntonio),
    Ceraiolo(id: 'c12', nome: 'David', cognome: 'Fioriti', soprannome: 'Dada', cero: CeroType.santAntonio),
  ];

  DatabaseHelper._init();

  static void resetInstance() {
    _database = null;
    _instance = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('muta.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
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
  dataModifica $nullableTextType,
  anno $intType,
  note $nullableTextType,
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
  soprannome $nullableTextType,
  ruolo $intType,
  note $nullableTextType,
  FOREIGN KEY (mutaId) REFERENCES mute (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE ceraioli (
  id $idType,
  nome $textType,
  cognome $textType,
  soprannome $nullableTextType,
  cero $intType
)
''');
  }

  Future<void> insertMuta(Muta muta) async {
    if (kIsWeb) {
      _webMute.removeWhere((m) => m.id == muta.id);
      _webMute.add(muta);
      return;
    }
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('mute', muta.toSqliteMap());
      for (var persona in muta.stangaSinistra) {
        final Map<String, dynamic> personMap = persona.toJson();
        personMap['mutaId'] = muta.id;
        personMap['isSinistra'] = 1;
        await txn.insert('persone', personMap);
      }
      for (var persona in muta.stangaDestra) {
        final Map<String, dynamic> personMap = persona.toJson();
        personMap['mutaId'] = muta.id;
        personMap['isSinistra'] = 0;
        await txn.insert('persone', personMap);
      }
    });
  }

  Future<Muta> readMuta(String id) async {
    if (kIsWeb) {
      return _webMute.firstWhere((m) => m.id == id, orElse: () => throw Exception('ID $id not found'));
    }
    final db = await instance.database;
    final maps = await db.query(
      'mute',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final mutaMap = maps.first;
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [id]);

      final stangaSinistra = personeMaps
          .where((p) => (p['isSinistra'] as int) == 1)
          .map((p) => PersonaMuta.fromJson(p))
          .toList();

      final stangaDestra = personeMaps
          .where((p) => (p['isSinistra'] as int) == 0)
          .map((p) => PersonaMuta.fromJson(p))
          .toList();

      return Muta.validateAndCreate(
        id: mutaMap['id'] as String,
        cero: CeroType.values[mutaMap['cero'] as int],
        nomeMuta: mutaMap['nomeMuta'] as String,
        posizione: mutaMap['posizione'] as String,
        latitude: mutaMap['latitude'] as double?,
        longitude: mutaMap['longitude'] as double?,
        stangaSinistra: stangaSinistra,
        stangaDestra: stangaDestra,
        dataCreazione: DateTime.parse(mutaMap['dataCreazione'] as String),
        dataModifica: mutaMap['dataModifica'] != null ? DateTime.parse(mutaMap['dataModifica'] as String) : null,
        anno: mutaMap['anno'] as int,
        note: mutaMap['note'] as String?,
        verificata: (mutaMap['verificata'] as int) == 1,
        numeroVerifiche: mutaMap['numeroVerifiche'] as int?,
      );
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Muta>> readAllMute() async {
    if (kIsWeb) {
      return List<Muta>.from(_webMute);
    }
    final db = await instance.database;
    final result = await db.query('mute');
    final muteList = <Muta>[];
    for (var mutaMap in result) {
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [mutaMap['id']]);
      final stangaSinistra = personeMaps.where((p) => (p['isSinistra'] as int) == 1).map((p) => PersonaMuta.fromJson(p)).toList();
      final stangaDestra = personeMaps.where((p) => (p['isSinistra'] as int) == 0).map((p) => PersonaMuta.fromJson(p)).toList();

      muteList.add(Muta.validateAndCreate(
        id: mutaMap['id'] as String,
        cero: CeroType.values[mutaMap['cero'] as int],
        nomeMuta: mutaMap['nomeMuta'] as String,
        posizione: mutaMap['posizione'] as String,
        latitude: mutaMap['latitude'] as double?,
        longitude: mutaMap['longitude'] as double?,
        stangaSinistra: stangaSinistra,
        stangaDestra: stangaDestra,
        dataCreazione: DateTime.parse(mutaMap['dataCreazione'] as String),
        dataModifica: mutaMap['dataModifica'] != null ? DateTime.parse(mutaMap['dataModifica'] as String) : null,
        anno: mutaMap['anno'] as int,
        note: mutaMap['note'] as String?,
        verificata: (mutaMap['verificata'] as int) == 1,
        numeroVerifiche: mutaMap['numeroVerifiche'] as int?,
      ));
    }
    return muteList;
  }

  Future<void> updateMuta(Muta muta) async {
    if (kIsWeb) {
      _webMute.removeWhere((m) => m.id == muta.id);
      _webMute.add(muta);
      return;
    }
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'mute',
        muta.toSqliteMap(),
        where: 'id = ?',
        whereArgs: [muta.id],
      );

      await txn.delete(
        'persone',
        where: 'mutaId = ?',
        whereArgs: [muta.id],
      );

      for (var persona in muta.stangaSinistra) {
        final Map<String, dynamic> personMap = persona.toJson();
        personMap['mutaId'] = muta.id;
        personMap['isSinistra'] = 1;
        await txn.insert('persone', personMap);
      }
      for (var persona in muta.stangaDestra) {
        final Map<String, dynamic> personMap = persona.toJson();
        personMap['mutaId'] = muta.id;
        personMap['isSinistra'] = 0;
        await txn.insert('persone', personMap);
      }
    });
  }

  Future<int> deleteMuta(String id) async {
    if (kIsWeb) {
      _webMute.removeWhere((m) => m.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'mute',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<int>> getAvailableYears() async {
    if (kIsWeb) {
      return _webMute.map((m) => m.anno).toSet().toList();
    }
    final db = await instance.database;
    final result = await db.query('mute', columns: ['anno'], distinct: true);
    return result.map((map) => map['anno'] as int).toList();
  }

  Future<List<Muta>> readMuteByYearAndCero(int year, CeroType cero) async {
    if (kIsWeb) {
      return _webMute.where((m) => m.anno == year && m.cero == cero).toList();
    }
    final db = await instance.database;
    final result = await db.query('mute', where: 'anno = ? AND cero = ?', whereArgs: [year, cero.index]);
    final muteList = <Muta>[];
    for (var mutaMap in result) {
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [mutaMap['id']]);
      final stangaSinistra = personeMaps.where((p) => (p['isSinistra'] as int) == 1).map((p) => PersonaMuta.fromJson(p)).toList();
      final stangaDestra = personeMaps.where((p) => (p['isSinistra'] as int) == 0).map((p) => PersonaMuta.fromJson(p)).toList();

      muteList.add(Muta.validateAndCreate(
        id: mutaMap['id'] as String,
        cero: CeroType.values[mutaMap['cero'] as int],
        nomeMuta: mutaMap['nomeMuta'] as String,
        posizione: mutaMap['posizione'] as String,
        latitude: mutaMap['latitude'] as double?,
        longitude: mutaMap['longitude'] as double?,
        stangaSinistra: stangaSinistra,
        stangaDestra: stangaDestra,
        dataCreazione: DateTime.parse(mutaMap['dataCreazione'] as String),
        dataModifica: mutaMap['dataModifica'] != null ? DateTime.parse(mutaMap['dataModifica'] as String) : null,
        anno: mutaMap['anno'] as int,
        note: mutaMap['note'] as String?,
        verificata: (mutaMap['verificata'] as int) == 1,
        numeroVerifiche: mutaMap['numeroVerifiche'] as int?,
      ));
    }
    return muteList;
  }

  Future<List<Muta>> searchMuteByPerson(String query) async {
    if (kIsWeb) {
      final q = query.toLowerCase();
      return _webMute.where((m) {
        return m.stangaSinistra.any((p) => p.nome.toLowerCase().contains(q) || p.cognome.toLowerCase().contains(q) || (p.soprannome?.toLowerCase().contains(q) ?? false)) ||
               m.stangaDestra.any((p) => p.nome.toLowerCase().contains(q) || p.cognome.toLowerCase().contains(q) || (p.soprannome?.toLowerCase().contains(q) ?? false));
      }).toList();
    }
    final db = await instance.database;
    final personeResult = await db.query('persone', where: 'nome LIKE ? OR cognome LIKE ? OR soprannome LIKE ?', whereArgs: ['%$query%', '%$query%', '%$query%']);
    final mutaIds = personeResult.map((map) => map['mutaId'] as String).toSet();
    if (mutaIds.isEmpty) {
      return [];
    }
    final muteResult = await db.query('mute', where: 'id IN (${mutaIds.map((_) => '?').join(', ')})', whereArgs: mutaIds.toList());
    final muteList = <Muta>[];
    for (var mutaMap in muteResult) {
      final personeMaps = await db.query('persone', where: 'mutaId = ?', whereArgs: [mutaMap['id']]);
      final stangaSinistra = personeMaps.where((p) => (p['isSinistra'] as int) == 1).map((p) => PersonaMuta.fromJson(p)).toList();
      final stangaDestra = personeMaps.where((p) => (p['isSinistra'] as int) == 0).map((p) => PersonaMuta.fromJson(p)).toList();

      muteList.add(Muta.validateAndCreate(
        id: mutaMap['id'] as String,
        cero: CeroType.values[mutaMap['cero'] as int],
        nomeMuta: mutaMap['nomeMuta'] as String,
        posizione: mutaMap['posizione'] as String,
        latitude: mutaMap['latitude'] as double?,
        longitude: mutaMap['longitude'] as double?,
        stangaSinistra: stangaSinistra,
        stangaDestra: stangaDestra,
        dataCreazione: DateTime.parse(mutaMap['dataCreazione'] as String),
        dataModifica: mutaMap['dataModifica'] != null ? DateTime.parse(mutaMap['dataModifica'] as String) : null,
        anno: mutaMap['anno'] as int,
        note: mutaMap['note'] as String?,
        verificata: (mutaMap['verificata'] as int) == 1,
        numeroVerifiche: mutaMap['numeroVerifiche'] as int?,
      ));
    }
    return muteList;
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }

  Future<void> insertCeraiolo(Ceraiolo ceraiolo) async {
    if (kIsWeb) {
      _webCeraioli.removeWhere((c) => c.id == ceraiolo.id);
      _webCeraioli.add(ceraiolo);
      return;
    }
    final db = await instance.database;
    await db.insert('ceraioli', ceraiolo.toJson());
  }

  Future<Ceraiolo> readCeraiolo(String id) async {
    if (kIsWeb) {
      return _webCeraioli.firstWhere((c) => c.id == id, orElse: () => throw Exception('ID $id not found in ceraioli registry'));
    }
    final db = await instance.database;
    final maps = await db.query(
      'ceraioli',
      columns: ['id', 'nome', 'cognome', 'soprannome', 'cero'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ceraiolo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in ceraioli registry');
    }
  }

  Future<List<Ceraiolo>> readAllCeraioliByCero(CeroType cero) async {
    if (kIsWeb) {
      final res = _webCeraioli.where((c) => c.cero == cero).toList();
      res.sort((a, b) {
        int cmp = a.cognome.compareTo(b.cognome);
        if (cmp != 0) return cmp;
        return a.nome.compareTo(b.nome);
      });
      return res;
    }
    final db = await instance.database;
    final result = await db.query('ceraioli', where: 'cero = ?', whereArgs: [cero.index], orderBy: 'cognome ASC, nome ASC');
    return result.map((json) => Ceraiolo.fromJson(json)).toList();
  }

  Future<List<Ceraiolo>> readAllCeraioli() async {
    if (kIsWeb) {
      final res = List<Ceraiolo>.from(_webCeraioli);
      res.sort((a, b) {
        int cmp = a.cognome.compareTo(b.cognome);
        if (cmp != 0) return cmp;
        return a.nome.compareTo(b.nome);
      });
      return res;
    }
    final db = await instance.database;
    final result = await db.query('ceraioli', orderBy: 'cognome ASC, nome ASC');
    return result.map((json) => Ceraiolo.fromJson(json)).toList();
  }

  Future<int> updateCeraiolo(Ceraiolo ceraiolo) async {
    if (kIsWeb) {
      _webCeraioli.removeWhere((c) => c.id == ceraiolo.id);
      _webCeraioli.add(ceraiolo);
      return 1;
    }
    final db = await instance.database;
    return db.update(
      'ceraioli',
      ceraiolo.toJson(),
      where: 'id = ?',
      whereArgs: [ceraiolo.id],
    );
  }

  Future<int> deleteCeraiolo(String id) async {
    if (kIsWeb) {
      _webCeraioli.removeWhere((c) => c.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'ceraioli',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Ceraiolo>> searchCeraioli(String query, {CeroType? cero}) async {
    if (kIsWeb) {
      var res = _webCeraioli;
      if (cero != null) {
        res = res.where((c) => c.cero == cero).toList();
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        res = res.where((c) => c.nome.toLowerCase().contains(q) || c.cognome.toLowerCase().contains(q) || (c.soprannome?.toLowerCase().contains(q) ?? false)).toList();
      }
      res.sort((a, b) {
        int cmp = a.cognome.compareTo(b.cognome);
        if (cmp != 0) return cmp;
        return a.nome.compareTo(b.nome);
      });
      return res;
    }
    final db = await instance.database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (cero != null) {
      whereClauses.add('cero = ?');
      whereArgs.add(cero.index);
    }

    if (query.isNotEmpty) {
      whereClauses.add('(nome LIKE ? OR cognome LIKE ? OR soprannome LIKE ?)');
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    final result = await db.query(
      'ceraioli',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'cognome ASC, nome ASC',
    );
    return result.map((json) => Ceraiolo.fromJson(json)).toList();
  }
}
