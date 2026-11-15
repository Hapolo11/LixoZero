import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dica.dart';
import '../models/guia_compostagem.dart';

/// Conteúdo educativo que vai junto com o app: o guia de compostagem (RF06)
/// e as dicas do rodapé da tela Buscar. Funciona sem internet (RNF03).
class ConteudoRepository {
  const ConteudoRepository(this.compostagem, this.dicas);

  final GuiaCompostagem compostagem;
  final List<Dica> dicas;

  static Future<ConteudoRepository> carregar() async {
    final compostagem = jsonDecode(await rootBundle.loadString('assets/data/compostagem.json'));
    final dicas = jsonDecode(await rootBundle.loadString('assets/data/dicas.json'));
    return ConteudoRepository(
      GuiaCompostagem.fromJson(compostagem),
      [for (final d in dicas['dicas']) Dica.fromJson(d)],
    );
  }
}
