import 'package:app_muta/theme/app_theme.dart'; // Per CeroType

// L'enum RuoloMuta definisce la posizione lungo una singola stanga
enum RuoloMuta {
  puntaAvanti,
  ceppoAvanti,
  ceppoDietro,
  puntaDietro,
}

class PersonaMuta {
  final String nome;
  final String cognome;
  final String? soprannome; // Nuovo campo
  final RuoloMuta ruolo; // Il ruolo della persona sulla sua stanga
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
      nome: json['nome'],
      cognome: json['cognome'],
      soprannome: json['soprannome'],
      ruolo: RuoloMuta.values[json['ruolo']],
      note: json['note'],
    );
  }

  // Helper per confronto
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
  final String nomeMuta; // Sostituisce numeroMuta
  final String posizione; // Può essere un riferimento geografico più specifico
  final double? latitude;
  final double? longitude;

  // Liste separate per le stanghe
  final List<PersonaMuta> stangaSinistra;
  final List<PersonaMuta> stangaDestra;

  final DateTime dataCreazione;
  final DateTime? dataModifica;
  final int anno;
  final String? note; // Note generali per la muta
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
  }) {
    assert(stangaSinistra.length == 4, 'La stanga sinistra deve avere 4 persone.');
    assert(stangaDestra.length == 4, 'La stanga destra deve avere 4 persone.');
    // Potresti aggiungere controlli per assicurarti che i ruoli siano unici e corretti per stanga
  }

  bool get isCompleta {
    if (stangaSinistra.length != 4 || stangaDestra.length != 4) return false;
    // Verifica che ogni stanga abbia i 4 ruoli distinti
    final ruoliSinistra = stangaSinistra.map((p) => p.ruolo).toSet();
    final ruoliDestra = stangaDestra.map((p) => p.ruolo).toSet();
    return ruoliSinistra.length == 4 && ruoliDestra.length == 4;
  }

  // Ottiene la persona per un ruolo specifico su una data stanga
  PersonaMuta? getPersonaPerRuoloEStanga(RuoloMuta ruolo, bool isSinistra) {
    final stanga = isSinistra ? stangaSinistra : stangaDestra;
    try {
      return stanga.firstWhere((p) => p.ruolo == ruolo);
    } catch (e) {
      return null; // Nessuna persona per quel ruolo su quella stanga
    }
  }

  // Ottiene le due persone (una per stanga) per un dato ruolo
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
    return Muta(
      id: json['id'],
      cero: CeroType.values[json['cero']],
      nomeMuta: json['nomeMuta'],
      posizione: json['posizione'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      stangaSinistra: (json['stangaSinistra'] as List)
          .map((p) => PersonaMuta.fromJson(p))
          .toList(),
      stangaDestra: (json['stangaDestra'] as List)
          .map((p) => PersonaMuta.fromJson(p))
          .toList(),
      dataCreazione: DateTime.parse(json['dataCreazione']),
      dataModifica: json['dataModifica'] != null
          ? DateTime.parse(json['dataModifica'])
          : null,
      anno: json['anno'],
      note: json['note'],
      verificata: json['verificata'] == 1,
      numeroVerifiche: json['numeroVerifiche'] ?? 0,
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
    return Muta(
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
