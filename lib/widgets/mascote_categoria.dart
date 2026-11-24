import 'package:flutter/material.dart';

/// Mascotes ilustrados de cada categoria de resíduo (tela Categorias).
///
/// As imagens ficam em `assets/mascotes/` e funcionam offline (RNF03),
/// pois vão empacotadas no próprio app.
class MascoteCategoria extends StatelessWidget {
  const MascoteCategoria({
    super.key,
    required this.categoria,
    this.tamanho = 110,
  });

  /// Nome da categoria como aparece no app: "Plástico", "Papel", "Vidro",
  /// "Orgânico", "Perigoso" ou "Metal" (aceita com ou sem acento).
  final String categoria;
  final double tamanho;

  static const Map<String, String> _caminhos = {
    'plastico': 'assets/mascotes/plastico.png',
    'papel': 'assets/mascotes/papel.png',
    'vidro': 'assets/mascotes/vidro.png',
    'organico': 'assets/mascotes/organico.png',
    'perigoso': 'assets/mascotes/perigoso.png',
    'metal': 'assets/mascotes/metal.png',
  };

  static String _normalizar(String texto) => texto
      .toLowerCase()
      .trim()
      .replaceAll('á', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');

  /// Caminho do asset para a categoria, ou null se não existir mascote.
  static String? caminhoPara(String categoria) =>
      _caminhos[_normalizar(categoria)];

  @override
  Widget build(BuildContext context) {
    final caminho = caminhoPara(categoria);
    if (caminho == null) return SizedBox(width: tamanho, height: tamanho);

    return Semantics(
      label: 'Mascotes da categoria $categoria',
      image: true,
      child: Image.asset(
        caminho,
        width: tamanho,
        height: tamanho,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // Se o asset faltar, não quebra o card.
        errorBuilder: (_, _, _) =>
            SizedBox(width: tamanho, height: tamanho),
      ),
    );
  }
}
