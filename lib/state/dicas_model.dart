import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dica.dart';

/// Escolhe a dica do rodapé da tela Buscar. Ela muda a cada abertura do app e
/// a cada busca, e não por temporizador, para não distrair nem gastar bateria
/// (Docs/justificativas.md, seção 5). Só o número da última dica fica salvo
/// no aparelho, para a próxima abertura continuar de onde parou.
class DicasModel extends ChangeNotifier {
  DicasModel(this.dicas, [SharedPreferences? prefs]) : _prefs = prefs, assert(dicas.isNotEmpty);

  static const chave = 'dica_atual';

  final List<Dica> dicas;
  SharedPreferences? _prefs;
  int _indice = 0;

  Dica get atual => dicas[_indice];

  /// Abertura do app: mostra a dica seguinte à última vista.
  /// Na primeira abertura, mostra a primeira (a do protótipo).
  Future<void> carregar() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final ultima = prefs.getInt(chave);
    _indice = ultima == null ? 0 : (ultima + 1) % dicas.length;
    await prefs.setInt(chave, _indice);
  }

  /// Chamado a cada busca.
  void proxima() {
    _indice = (_indice + 1) % dicas.length;
    _prefs?.setInt(chave, _indice);
    notifyListeners();
  }
}
