import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/item_guia.dart';
import '../services/reconhecimento_imagem.dart';
import 'guia_repository.dart';

/// Liga os rótulos do reconhecimento de imagem (assets/data/rotulos.json) aos
/// itens do guia, para a foto virar uma busca (RF08).
class RotulosRepository {
  RotulosRepository(Map<String, List<String>> rotulos)
      : rotulos = {for (final e in rotulos.entries) _normalizar(e.key): e.value};

  /// rótulo (minúsculo) -> ids dos itens do guia, do mais ao menos provável
  final Map<String, List<String>> rotulos;

  static Future<RotulosRepository> carregar() async {
    final json = jsonDecode(await rootBundle.loadString('assets/data/rotulos.json')) as Map<String, dynamic>;
    final bruto = json['rotulos'] as Map<String, dynamic>;
    return RotulosRepository({
      for (final e in bruto.entries) e.key: List<String>.from(e.value as List<dynamic>),
    });
  }

  static String _normalizar(String texto) => texto.trim().toLowerCase();

  /// Os itens do guia mais prováveis para os [rotulos] da foto, do melhor para
  /// o pior. Cada rótulo soma a sua confiança aos itens que ele indica, e os
  /// itens que aparecem mais atrás na lista do rótulo valem um pouco menos.
  List<ItemGuia> sugerir(List<RotuloImagem> encontrados, GuiaRepository guia, {int limite = 3}) {
    final porId = {for (final item in guia.itens) item.id: item};
    final pontos = <String, double>{};

    for (final rotulo in encontrados) {
      final ids = rotulos[_normalizar(rotulo.texto)];
      if (ids == null) continue;
      for (var i = 0; i < ids.length; i++) {
        if (!porId.containsKey(ids[i])) continue;
        final peso = (1 - 0.2 * i).clamp(0.2, 1.0);
        pontos.update(ids[i], (v) => v + rotulo.confianca * peso, ifAbsent: () => rotulo.confianca * peso);
      }
    }

    final ordenados = pontos.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in ordenados.take(limite)) porId[e.key]!];
  }
}
