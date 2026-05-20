import 'package:muta_manager/theme/app_theme.dart';

class InvalidStangaLengthException implements Exception {
  final String message;
  const InvalidStangaLengthException(this.message);

  @override
  String toString() => 'InvalidStangaLengthException: $message';
}

enum RuoloMuta {
  puntaAvanti,
  ceppoAvanti,
  ceppoDietro,
  puntaDietro,
}

class PersonaMuta {
  final String nome;
  final String cognome;
  final String? soprannome;
  final RuoloMuta ruolo;
  final String? note;

  PersonaMuta({
    required this.nome,
    required this.cognome,
    this.soprannome,
    required this.ruolo,
    this.note,
  });

  String get nomeCompleto {
    if (soprannome != null && soprannome!.isNotEmpty) {
      return '$nome "$soprannome" $cognome';
    }
    return '$nome $cognome';
  }

  String get ruoloDescrizione {
    switch (ruolo) {
      case RuoloMuta.puntaAvanti:
        return 'Punta Avanti';
      case RuoloMuta.ceppoAvanti:
        return 'Ceppo Avanti';
      case RuoloMuta.ceppoDietro:
        return 'Ceppo Dietro';
      case RuoloMuta.puntaDietro:
        return 'Punta Dietro';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cognome': cognome,
      'soprannome': soprannome,
      'ruolo': ruolo.index,
      'note': note,
    };
  }

  factory PersonaMuta.fromJson(Map<String, dynamic> json) {
    return PersonaMuta(
      nome: json['nome'] as String? ?? '',
      cognome: json['cognome'] as String? ?? '',
      soprannome: json['soprannome'] as String?,
      ruolo: RuoloMuta.values[json['ruolo'] as int? ?? 0],
      note: json['note'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PersonaMuta &&
              runtimeType == other.runtimeType &&
              nome == other.nome &&
              cognome == other.cognome &&
              soprannome == other.soprannome &&
              ruolo == other.ruolo;

  @override
  int get hashCode => nome.hashCode ^ cognome.hashCode ^ soprannome.hashCode ^ ruolo.hashCode;
}

class Muta {
  final String id;
  final CeroType cero;
  final String nomeMuta;
  final String posizione;
  final double? latitude;
  final double? longitude;

  final List<PersonaMuta> stangaSinistra;
  final List<PersonaMuta> stangaDestra;

  final DateTime dataCreazione;
  final DateTime? dataModifica;
  final int anno;
  final String? note;
  final bool verificata;
  final int? numeroVerifiche;

  Muta({
    required this.id,
    required this.cero,
    required this.nomeMuta,
    required this.posizione,
    this.latitude,
    this.longitude,
    required this.stangaSinistra,
    required this.stangaDestra,
    required this.dataCreazione,
    this.dataModifica,
    required this.anno,
    this.note,
    this.verificata = false,
    this.numeroVerifiche = 0,
  });

  factory Muta.validateAndCreate({
    required String id,
    required CeroType cero,
    required String nomeMuta,
    required String posizione,
    double? latitude,
    double? longitude,
    required List<PersonaMuta> stangaSinistra,
    required List<PersonaMuta> stangaDestra,
    required DateTime dataCreazione,
    DateTime? dataModifica,
    required int anno,
    String? note,
    bool verificata = false,
    int? numeroVerifiche = 0,
  }) {
    if (stangaSinistra.length != 4) {
      throw InvalidStangaLengthException('La stanga sinistra deve contenere esattamente 4 persone (trovate: ${stangaSinistra.length}).');
    }
    if (stangaDestra.length != 4) {
      throw InvalidStangaLengthException('La stanga destra deve contenere esattamente 4 persone (trovate: ${stangaDestra.length}).');
    }
    return Muta(
      id: id,
      cero: cero,
      nomeMuta: nomeMuta,
      posizione: posizione,
      latitude: latitude,
      longitude: longitude,
      stangaSinistra: List<PersonaMuta>.unmodifiable(stangaSinistra),
      stangaDestra: List<PersonaMuta>.unmodifiable(stangaDestra),
      dataCreazione: dataCreazione,
      dataModifica: dataModifica,
      anno: anno,
      note: note,
      verificata: verificata,
      numeroVerifiche: numeroVerifiche,
    );
  }

  bool get isCompleta {
    if (stangaSinistra.length != 4 || stangaDestra.length != 4) return false;
    final ruoliSinistra = stangaSinistra.map((p) => p.ruolo).toSet();
    final ruoliDestra = stangaDestra.map((p) => p.ruolo).toSet();
    return ruoliSinistra.length == 4 && ruoliDestra.length == 4;
  }

  PersonaMuta? getPersonaPerRuoloEStanga(RuoloMuta ruolo, bool isSinistra) {
    final stanga = isSinistra ? stangaSinistra : stangaDestra;
    try {
      return stanga.firstWhere((p) => p.ruolo == ruolo);
    } catch (e) {
      return null;
    }
  }

  List<PersonaMuta> getPersonePerRuolo(RuoloMuta ruolo) {
    List<PersonaMuta> risultato = [];
    final pSinistra = getPersonaPerRuoloEStanga(ruolo, true);
    if (pSinistra != null) risultato.add(pSinistra);
    final pDestra = getPersonaPerRuoloEStanga(ruolo, false);
    if (pDestra != null) risultato.add(pDestra);
    return risultato;
  }

  String get ceroNome {
    switch (cero) {
      case CeroType.santUbaldo:
        return "Sant'Ubaldo";
      case CeroType.sanGiorgio:
        return "San Giorgio";
      case CeroType.santAntonio:
        return "Sant'Antonio";
    }
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'cero': cero.index,
      'nomeMuta': nomeMuta,
      'posizione': posizione,
      'latitude': latitude,
      'longitude': longitude,
      'dataCreazione': dataCreazione.toIso8601String(),
      'dataModifica': dataModifica?.toIso8601String(),
      'anno': anno,
      'note': note,
      'verificata': verificata ? 1 : 0,
      'numeroVerifiche': numeroVerifiche ?? 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cero': cero.index,
      'nomeMuta': nomeMuta,
      'posizione': posizione,
      'latitude': latitude,
      'longitude': longitude,
      'stangaSinistra': stangaSinistra.map((p) => p.toJson()).toList(),
      'stangaDestra': stangaDestra.map((p) => p.toJson()).toList(),
      'dataCreazione': dataCreazione.toIso8601String(),
      'dataModifica': dataModifica?.toIso8601String(),
      'anno': anno,
      'note': note,
      'verificata': verificata ? 1 : 0,
      'numeroVerifiche': numeroVerifiche,
    };
  }

  factory Muta.fromJson(Map<String, dynamic> json) {
    return Muta.validateAndCreate(
      id: json['id'] as String? ?? '',
      cero: CeroType.values[json['cero'] as int? ?? 0],
      nomeMuta: json['nomeMuta'] as String? ?? '',
      posizione: json['posizione'] as String? ?? '',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      stangaSinistra: (json['stangaSinistra'] as List? ?? [])
          .map((p) => PersonaMuta.fromJson(p as Map<String, dynamic>))
          .toList(),
      stangaDestra: (json['stangaDestra'] as List? ?? [])
          .map((p) => PersonaMuta.fromJson(p as Map<String, dynamic>))
          .toList(),
      dataCreazione: DateTime.parse(json['dataCreazione'] as String? ?? DateTime.now().toIso8601String()),
      dataModifica: json['dataModifica'] != null ? DateTime.parse(json['dataModifica'] as String) : null,
      anno: json['anno'] as int? ?? DateTime.now().year,
      note: json['note'] as String?,
      verificata: json['verificata'] == 1,
      numeroVerifiche: json['numeroVerifiche'] as int? ?? 0,
    );
  }

  Muta copyWith({
    String? id,
    CeroType? cero,
    String? nomeMuta,
    String? posizione,
    double? latitude,
    double? longitude,
    List<PersonaMuta>? stangaSinistra,
    List<PersonaMuta>? stangaDestra,
    DateTime? dataCreazione,
    DateTime? dataModifica,
    int? anno,
    String? note,
    bool? verificata,
    int? numeroVerifiche,
  }) {
    return Muta.validateAndCreate(
      id: id ?? this.id,
      cero: cero ?? this.cero,
      nomeMuta: nomeMuta ?? this.nomeMuta,
      posizione: posizione ?? this.posizione,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      stangaSinistra: stangaSinistra ?? this.stangaSinistra,
      stangaDestra: stangaDestra ?? this.stangaDestra,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
      anno: anno ?? this.anno,
      note: note ?? this.note,
      verificata: verificata ?? this.verificata,
      numeroVerifiche: numeroVerifiche ?? this.numeroVerifiche,
    );
  }
}
