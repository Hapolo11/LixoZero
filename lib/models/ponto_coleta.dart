class PontoColeta {
  const PontoColeta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.endereco,
    required this.bairro,
    required this.lat,
    required this.lng,
    required this.precisao,
    required this.horario,
    required this.aceita,
    this.telefone,
  });

  final String id;
  final String nome;
  final String tipo; // 'ecoponto' ou 'cooperativa'
  final String endereco;
  final String bairro;
  final double lat;
  final double lng;
  final String precisao; // 'rua' ou 'bairro' (quando o endereço não tem número)
  final String horario;
  final List<String> aceita;
  final String? telefone;

  bool get ehCooperativa => tipo == 'cooperativa';

  factory PontoColeta.fromJson(Map<String, dynamic> json) {
    return PontoColeta(
      id: json['id'],
      nome: json['nome'],
      tipo: json['tipo'],
      endereco: json['endereco'],
      bairro: json['bairro'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      precisao: json['precisao'],
      horario: json['horario'],
      aceita: List<String>.from(json['aceita']),
      telefone: json['telefone'],
    );
  }
}
