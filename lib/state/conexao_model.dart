import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Avisa as telas quando a internet cai ou volta (o mapa depende dela).
class ConexaoModel extends ChangeNotifier {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _escuta;
  bool _online = true;

  bool get online => _online;

  Future<void> iniciar() async {
    try {
      _atualizar(await _connectivity.checkConnectivity());
      _escuta = _connectivity.onConnectivityChanged.listen(_atualizar);
    } catch (_) {
      // Nos testes o plugin não existe; nesse caso fica como online.
    }
  }

  void _atualizar(List<ConnectivityResult> resultado) {
    final online = resultado.any((r) => r != ConnectivityResult.none);
    if (online == _online) return;
    _online = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _escuta?.cancel();
    super.dispose();
  }
}
