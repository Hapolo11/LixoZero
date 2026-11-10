import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro_reciclagem.dart';

/// Carrega e salva os registros de reciclagem em SharedPreferences.
/// Fica tudo local no aparelho (sem coletar dados pessoais).
class ReciclagemRepository {
  ReciclagemRepository([SharedPreferences? prefs]) : _prefs = prefs;

  static const chave = 'registros_reciclagem';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _obterPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<RegistroReciclagem>> carregar() async {
    final prefs = await _obterPrefs();
    final raw = prefs.getString(chave);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RegistroReciclagem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> salvar(List<RegistroReciclagem> registros) async {
    final prefs = await _obterPrefs();
    final raw = jsonEncode(registros.map((r) => r.toJson()).toList());
    await prefs.setString(chave, raw);
  }
}

