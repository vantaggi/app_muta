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
      id: json['id'],
      nome: json['nome'],
      cognome: json['cognome'],
      soprannome: json['soprannome'],
      cero: json['cero'] != null ? CeroType.values[json['cero']] : CeroType.santUbaldo,
    );
  }

  String get nomeCompleto {
    if (soprannome != null && soprannome!.isNotEmpty) {
      return '$nome "$soprannome" $cognome';
    }
    return '$nome $cognome';
  }
}
