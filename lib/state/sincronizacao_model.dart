import 'package:flutter/foundation.dart';

import 'auth_model.dart';
import 'conexao_model.dart';
import 'lembretes_model.dart';
import 'reciclagem_model.dart';

enum EstadoSincronizacao {
  /// Visitante: os dados ficam só neste aparelho.
  semConta,

  /// Tem conta, mas está sem internet. Os envios esperam a conexão voltar.
  aguardandoInternet,

  sincronizando,

  sincronizado,

  /// Falhou (por exemplo, o Firestore ainda não foi criado ou as regras negaram).
  erro,
}

/// Mantém os dados de quem tem conta em dia com o Firestore (UC18).
///
/// Sincroniza quando a pessoa entra na conta e quando a internet volta. Os
/// registros e lembretes novos são enviados na hora, pelos próprios modelos.
class SincronizacaoModel extends ChangeNotifier {
  SincronizacaoModel({
    required this._auth,
    required this._conexao,
    required this._reciclagem,
    required this._lembretes,
  }) {
    _auth.addListener(_aoMudar);
    _conexao.addListener(_aoMudar);
    _aoMudar();
  }

  final AuthModel _auth;
  final ConexaoModel _conexao;
  final ReciclagemModel _reciclagem;
  final LembretesModel _lembretes;

  EstadoSincronizacao _estado = EstadoSincronizacao.semConta;
  DateTime? _sincronizadoEm;
  String? _uid;
  bool _estavaOnline = false;
  bool _ocupado = false;

  EstadoSincronizacao get estado => _estado;

  /// Quando a última sincronização terminou, se já terminou alguma.
  DateTime? get sincronizadoEm => _sincronizadoEm;

  void _aoMudar() {
    final uid = _auth.usuario?.uid;
    final online = _conexao.online;
    final trocouUsuario = uid != _uid;
    final voltouInternet = online && !_estavaOnline;
    _estavaOnline = online;

    if (trocouUsuario) {
      _uid = uid;
      _sincronizadoEm = null;
      _reciclagem.definirUsuario(uid);
      _lembretes.definirUsuario(uid);
    }

    if (uid == null) {
      _mudarEstado(EstadoSincronizacao.semConta);
      return;
    }
    if (!online) {
      _mudarEstado(EstadoSincronizacao.aguardandoInternet);
      return;
    }
    if (trocouUsuario || voltouInternet) sincronizarAgora();
  }

  /// Também usado pelo botão "Sincronizar agora", depois de uma falha.
  Future<void> sincronizarAgora() async {
    if (_ocupado || _uid == null) return;
    _ocupado = true;
    _mudarEstado(EstadoSincronizacao.sincronizando);
    try {
      await _reciclagem.sincronizar();
      await _lembretes.sincronizar();
      _sincronizadoEm = DateTime.now();
      _mudarEstado(EstadoSincronizacao.sincronizado);
    } catch (e) {
      debugPrint('Falha ao sincronizar: $e');
      _mudarEstado(EstadoSincronizacao.erro);
    } finally {
      _ocupado = false;
    }
  }

  void _mudarEstado(EstadoSincronizacao novo) {
    if (_estado == novo && novo != EstadoSincronizacao.sincronizado) return;
    _estado = novo;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_aoMudar);
    _conexao.removeListener(_aoMudar);
    super.dispose();
  }
}
