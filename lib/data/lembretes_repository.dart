import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lembrete.dart';

/// Salva os lembretes de coleta no aparelho (SharedPreferences), sem servidor.
class LembretesRepository {
  LembretesRepository([SharedPreferences? prefs]) : _prefs = prefs;

  static const chave = 'lembretes_coleta';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _obterPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Lembrete>> carregar() async {
    final prefs = await _obterPrefs();
    final raw = prefs.getString(chave);
    if (raw == null || raw.isEmpty) return [];
    try {
      final lista = jsonDecode(raw) as List<dynamic>;
      return lista.map((e) => Lembrete.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Dado corrompido não pode travar a tela de Impacto.
      return [];
    }
  }

  Future<void> salvar(List<Lembrete> lembretes) async {
    final prefs = await _obterPrefs();
    await prefs.setString(chave, jsonEncode(lembretes.map((l) => l.toJson()).toList()));
  }
}
