import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/categoria.dart';
import '../models/item_guia.dart';
import 'busca.dart';

/// Lê o guia de classificação (assets/data/guia.json), que vai junto com o app.
/// Para incluir ou corrigir um resíduo, é só editar o JSON.
class GuiaRepository {
  GuiaRepository(this.categorias, this.itens, this.destinos) : busca = BuscaGuia(itens);

  final List<Categoria> categorias;
  final List<ItemGuia> itens;
  final Map<String, String> destinos;
  final BuscaGuia busca;

  static Future<GuiaRepository> carregar() async {
    final json = jsonDecode(await rootBundle.loadString('assets/data/guia.json'));
    return GuiaRepository(
      [for (final c in json['categorias']) Categoria.fromJson(c)],
      [for (final i in json['itens']) ItemGuia.fromJson(i)],
      Map<String, String>.from(json['destinos']),
    );
  }

  Categoria categoria(String id) => categoriaEspecial(id) ?? categorias.firstWhere((c) => c.id == id);

  String destino(String id) => destinos[id] ?? id;
}
