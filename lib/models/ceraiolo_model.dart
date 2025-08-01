class Ceraiolo {
  final String id;
  final String nome;
  final String cognome;
  final String? soprannome;

  Ceraiolo({
    required this.id,
    required this.nome,
    required this.cognome,
    this.soprannome,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'soprannome': soprannome,
    };
  }

  factory Ceraiolo.fromJson(Map<String, dynamic> json) {
    return Ceraiolo(
      id: json['id'],
      nome: json['nome'],
      cognome: json['cognome'],
      soprannome: json['soprannome'],
    );
  }
}
