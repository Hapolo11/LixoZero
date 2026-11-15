import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Categoria {
  const Categoria({
    required this.id,
    required this.nome,
    required this.lixeira,
    required this.cor,
    required this.descricao,
    required this.exemplos,
  });

  final String id;
  final String nome;
  final String lixeira;
  final Color cor;
  final String descricao;
  final List<String> exemplos;

  factory Categoria.fromJson(Map<String, dynamic> json) {
    final hex = (json['cor'] as String).replaceFirst('#', 'FF');
    return Categoria(
      id: json['id'],
      nome: json['nome'],
      lixeira: json['lixeira'],
      cor: Color(int.parse(hex, radix: 16)),
      descricao: json['descricao'],
      exemplos: List<String>.from(json['exemplos']),
    );
  }

  IconData get icone => iconeDaCategoria(id);
}

// Alguns itens do guia não são de nenhuma das 6 categorias (fralda, sofá...).
// Eles aparecem na busca em cinza, mas não na tela de categorias.
const rejeito = 'rejeito';
const volumoso = 'volumoso';

const _especiais = {
  rejeito: Categoria(
    id: rejeito,
    nome: 'Lixo comum',
    lixeira: 'Não reciclável',
    cor: AppColors.cinza,
    descricao: 'Não é reciclável e vai para o lixo comum.',
    exemplos: [],
  ),
  volumoso: Categoria(
    id: volumoso,
    nome: 'Volumoso',
    lixeira: 'Ecoponto',
    cor: AppColors.cinza,
    descricao: 'Móveis, entulho e outros itens grandes vão para o ecoponto.',
    exemplos: [],
  ),
};

Categoria? categoriaEspecial(String id) => _especiais[id];

IconData iconeDaCategoria(String id) {
  switch (id) {
    case 'plastico':
      return Icons.local_drink_outlined;
    case 'papel':
      return Icons.description_outlined;
    case 'vidro':
      return Icons.wine_bar_outlined;
    case 'metal':
      return Icons.hardware_outlined;
    case 'organico':
      return Icons.eco_outlined;
    case 'perigoso':
      return Icons.battery_alert_outlined;
    case volumoso:
      return Icons.chair_outlined;
    default:
      return Icons.delete_outline;
  }
}
