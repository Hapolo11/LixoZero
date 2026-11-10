/// Dica curta do rodapé da tela Buscar (assets/data/dicas.json).
class Dica {
  const Dica({
    required this.id,
    required this.tema,
    required this.titulo,
    required this.texto,
    this.abreCompostagem = false,
    this.busca,
  });

  final String id;
  final String tema; // aparece em "Dica: compostagem"
  final String titulo;
  final String texto;
  final bool abreCompostagem; // mostra o botão do guia de compostagem
  final String? busca; // mostra o botão que procura o item no guia

  factory Dica.fromJson(Map<String, dynamic> json) {
    return Dica(
      id: json['id'],
      tema: json['tema'],
      titulo: json['titulo'],
      texto: json['texto'],
      abreCompostagem: json['compostagem'] ?? false,
      busca: json['busca'],
    );
  }
}
