import 'package:muta_manager/theme/app_theme.dart';

class Ceraiolo {
  final String id;
  final String nome;
  final String cognome;
  final String? soprannome;
  final CeroType cero;

  Ceraiolo({
    required this.id,
    required this.nome,
    required this.cognome,
    this.soprannome,
    required this.cero,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'soprannome': soprannome,
      'cero': cero.index,
    };
  }

  factory Ceraiolo.fromJson(Map<String, dynamic> json) {
    return Ceraiolo(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      cognome: json['cognome']?.toString() ?? '',
      soprannome: json['soprannome']?.toString(),
      cero: json['cero'] != null
          ? (json['cero'] >= 0 && json['cero'] < CeroType.values.length
              ? CeroType.values[json['cero']]
              : CeroType.santUbaldo)
          : CeroType.santUbaldo,
    );
  }

  String get nomeCompleto {
    if (soprannome != null && soprannome!.isNotEmpty) {
      return '$nome "$soprannome" $cognome';
    }
    return '$nome $cognome';
  }

  String get ceroDescrizione {
    switch (cero) {
      case CeroType.santUbaldo:
        return "Sant'Ubaldo";
      case CeroType.sanGiorgio:
        return "San Giorgio";
      case CeroType.santAntonio:
        return "Sant'Antonio";
    }
  }

  @override
  String toString() {
    return '$nomeCompleto (Cero: $ceroDescrizione)';
  }
}
