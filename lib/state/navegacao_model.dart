import 'package:flutter/foundation.dart';

enum Aba { buscar, mapa, impacto, categorias }

/// Guarda a aba aberta e deixa uma tela mandar o usuário para outra
/// (por exemplo, de um resultado da busca direto para o mapa).
class NavegacaoModel extends ChangeNotifier {
  Aba _aba = Aba.buscar;
  String? _filtroMapa;
  String? _buscaPendente;

  Aba get aba => _aba;
  String? get filtroMapa => _filtroMapa;

  void irPara(Aba aba) {
    if (aba == _aba) return;
    _aba = aba;
    notifyListeners();
  }

  /// Botão "Ver pontos de coleta": abre o mapa já filtrado pela categoria.
  void verPontosDeColeta(String categoria) {
    _filtroMapa = categoria;
    _aba = Aba.mapa;
    notifyListeners();
  }

  void filtrarMapa(String? categoria) {
    _filtroMapa = categoria;
    notifyListeners();
  }

  /// Tocar num exemplo da tela de categorias faz a busca por ele.
  void buscar(String termo) {
    _buscaPendente = termo;
    _aba = Aba.buscar;
    notifyListeners();
  }

  /// A tela de busca chama isso para pegar o termo (só uma vez).
  String? pegarBuscaPendente() {
    final termo = _buscaPendente;
    _buscaPendente = null;
    return termo;
  }
}
