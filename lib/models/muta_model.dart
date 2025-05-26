import 'package:app_muta/theme/app_theme.dart';

enum RuoloMuta {
  puntaAvanti,
  ceppoAvanti,
  ceppoDietro,
  puntaDietro,
}

class PersonaMuta {
  final String nome;
  final String cognome;
  final RuoloMuta ruolo;
  final String? note;

  PersonaMuta({
    required this.nome,
    required this.cognome,
    required this.ruolo,
    this.note,
  });

  String get nomeCompleto => '$nome $cognome';

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
      'ruolo': ruolo.index,
      'note': note,
    };
  }

  factory PersonaMuta.fromJson(Map<String, dynamic> json) {
    return PersonaMuta(
      nome: json['nome'],
      cognome: json['cognome'],
      ruolo: RuoloMuta.values[json['ruolo']],
      note: json['note'],
    );
  }
}

class Muta {
  final String id;
  final CeroType cero;
  final int numeroMuta;
  final String posizione; // es. "Via del Corso, 15"
  final List<PersonaMuta> persone;
  final DateTime dataCreazione;
  final DateTime? dataModifica;
  final int anno;
  final String? note;
  final bool verificata;
  final int? numeroVerifiche; // Quante volte è stata confermata da utenti diversi

  Muta({
    required this.id,
    required this.cero,
    required this.numeroMuta,
    required this.posizione,
    required this.persone,
    required this.dataCreazione,
    this.dataModifica,
    required this.anno,
    this.note,
    this.verificata = false,
    this.numeroVerifiche = 0,
  });

  // Verifica se la muta è completa (8 persone, 2 per ogni ruolo)
  bool get isCompleta {
    if (persone.length != 8) return false;

    final ruoliCount = <RuoloMuta, int>{};
    for (final persona in persone) {
      ruoliCount[persona.ruolo] = (ruoliCount[persona.ruolo] ?? 0) + 1;
    }

    return ruoliCount[RuoloMuta.puntaAvanti] == 2 &&
        ruoliCount[RuoloMuta.ceppoAvanti] == 2 &&
        ruoliCount[RuoloMuta.ceppoDietro] == 2 &&
        ruoliCount[RuoloMuta.puntaDietro] == 2;
  }

  // Ottieni le persone per ruolo
  List<PersonaMuta> getPersonePerRuolo(RuoloMuta ruolo) {
    return persone.where((p) => p.ruolo == ruolo).toList();
  }

  // Ottieni tutte le persone ordinate per posizione (ordine di marcia)
  List<PersonaMuta> get personeOrdinate {
    final ordinate = <PersonaMuta>[];

    // Ordine di marcia: punta avanti, ceppo avanti, ceppo dietro, punta dietro
    for (final ruolo in RuoloMuta.values) {
      ordinate.addAll(getPersonePerRuolo(ruolo));
    }

    return ordinate;
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
      'numeroMuta': numeroMuta,
      'posizione': posizione,
      'persone': persone.map((p) => p.toJson()).toList(),
      'dataCreazione': dataCreazione.millisecondsSinceEpoch,
      'dataModifica': dataModifica?.millisecondsSinceEpoch,
      'anno': anno,
      'note': note,
      'verificata': verificata,
      'numeroVerifiche': numeroVerifiche,
    };
  }

  factory Muta.fromJson(Map<String, dynamic> json) {
    return Muta(
      id: json['id'],
      cero: CeroType.values[json['cero']],
      numeroMuta: json['numeroMuta'],
      posizione: json['posizione'],
      persone: (json['persone'] as List)
          .map((p) => PersonaMuta.fromJson(p))
          .toList(),
      dataCreazione: DateTime.fromMillisecondsSinceEpoch(json['dataCreazione']),
      dataModifica: json['dataModifica'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dataModifica'])
          : null,
      anno: json['anno'],
      note: json['note'],
      verificata: json['verificata'] ?? false,
      numeroVerifiche: json['numeroVerifiche'] ?? 0,
    );
  }

  // Crea una copia della muta con modifiche
  Muta copyWith({
    String? id,
    CeroType? cero,
    int? numeroMuta,
    String? posizione,
    List<PersonaMuta>? persone,
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
      numeroMuta: numeroMuta ?? this.numeroMuta,
      posizione: posizione ?? this.posizione,
      persone: persone ?? this.persone,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
      anno: anno ?? this.anno,
      note: note ?? this.note,
      verificata: verificata ?? this.verificata,
      numeroVerifiche: numeroVerifiche ?? this.numeroVerifiche,
    );
  }
}