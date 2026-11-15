import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_repositorio.dart';

/// Em que ponto o usuário está em relação ao login.
enum Sessao {
  /// Ainda não decidiu: mostra a tela de login.
  precisaEscolher,

  /// Escolheu "Não quero fazer login": usa o app inteiro sem conta.
  visitante,

  /// Entrou com uma conta.
  logado,
}

/// Guarda a sessão. O login é opcional (RNF06): quem toca em
/// "Não quero fazer login" usa tudo, e a escolha fica salva no aparelho.
class AuthModel extends ChangeNotifier {
  AuthModel(this._repo, this._prefs) {
    _usuario = _repo.atual;
    _escolheuVisitante = _prefs.getBool(_chaveVisitante) ?? false;
    _assinatura = _repo.mudancas.listen((u) {
      _usuario = u;
      notifyListeners();
    });
  }

  static const _chaveVisitante = 'visitante';

  final AuthRepositorio _repo;
  final SharedPreferences _prefs;
  late final StreamSubscription<UsuarioConta?> _assinatura;

  UsuarioConta? _usuario;
  bool _escolheuVisitante = false;

  bool get loginDisponivel => _repo.disponivel;
  UsuarioConta? get usuario => _usuario;

  Sessao get sessao {
    if (_usuario != null) return Sessao.logado;
    return _escolheuVisitante ? Sessao.visitante : Sessao.precisaEscolher;
  }

  Future<void> continuarSemLogin() async {
    _escolheuVisitante = true;
    await _prefs.setBool(_chaveVisitante, true);
    notifyListeners();
  }

  /// Visitante que resolveu criar conta ou entrar: volta para a tela de login.
  Future<void> pedirLogin() async {
    _escolheuVisitante = false;
    await _prefs.setBool(_chaveVisitante, false);
    notifyListeners();
  }

  Future<void> entrar(String email, String senha) async {
    await _repo.entrar(email, senha);
    await _lembrarQueEntrou();
  }

  Future<void> criarConta({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  }) async {
    await _repo.criarConta(nome: nome, sobrenome: sobrenome, email: email, senha: senha);
    await _lembrarQueEntrou();
  }

  Future<void> redefinirSenha(String email) => _repo.redefinirSenha(email);

  /// false se o usuário desistiu na janela do Google.
  Future<bool> entrarComGoogle() async {
    final entrou = await _repo.entrarComGoogle();
    if (entrou) await _lembrarQueEntrou();
    return entrou;
  }

  Future<void> atualizarNome(String nome) async {
    await _repo.atualizarNome(nome);
    _usuario = _repo.atual;
    notifyListeners();
  }

  /// Sair da conta volta para a tela de login.
  Future<void> sair() async {
    await _repo.sair();
    _usuario = null;
    await pedirLogin();
  }

  Future<void> excluirConta() async {
    await _repo.excluirConta();
    _usuario = null;
    await pedirLogin();
  }

  Future<void> _lembrarQueEntrou() async {
    _usuario = _repo.atual;
    _escolheuVisitante = false;
    await _prefs.setBool(_chaveVisitante, false);
    notifyListeners();
  }

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }
}
