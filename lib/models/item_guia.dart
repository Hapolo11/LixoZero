class ItemGuia {
  const ItemGuia({
    required this.id,
    required this.nome,
    required this.sinonimos,
    required this.categoriaId,
    required this.destino,
    required this.pesoKg,
    required this.instrucao,
  });

  final String id;
  final String nome;
  final List<String> sinonimos;
  final String categoriaId;
  final String destino;
  final double pesoKg; // peso médio, para o contador de impacto
  final String instrucao;

  factory ItemGuia.fromJson(Map<String, dynamic> json) {
    return ItemGuia(
      id: json['id'],
      nome: json['nome'],
      sinonimos: List<String>.from(json['sinonimos']),
      categoriaId: json['categoria'],
      destino: json['destino'],
      pesoKg: (json['pesoKg'] as num).toDouble(),
      instrucao: json['instrucao'],
    );
  }
}
