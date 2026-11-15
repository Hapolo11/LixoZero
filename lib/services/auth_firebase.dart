import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repositorio.dart';

/// Login com Firebase Authentication (e-mail e senha, e Google).
class AuthFirebase implements AuthRepositorio {
  AuthFirebase(this._auth);

  final FirebaseAuth _auth;

  @override
  bool get disponivel => true;

  @override
  UsuarioConta? get atual => _converter(_auth.currentUser);

  @override
  Stream<UsuarioConta?> get mudancas => _auth.userChanges().map(_converter);

  UsuarioConta? _converter(User? usuario) {
    if (usuario == null) return null;
    return UsuarioConta(uid: usuario.uid, email: usuario.email ?? '', nome: usuario.displayName);
  }

  Future<T> _tentar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on FirebaseAuthException catch (e) {
      throw AuthFalha(mensagemDoErro(e.code));
    }
  }

  @override
  Future<void> entrar(String email, String senha) {
    return _tentar(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: senha));
  }

  @override
  Future<void> criarConta({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  }) {
    return _tentar(() async {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: senha);
      await cred.user?.updateDisplayName('${nome.trim()} ${sobrenome.trim()}');
      // Sem o reload, o nome novo só aparece depois do próximo login.
      await cred.user?.reload();
    });
  }

  @override
  Future<void> redefinirSenha(String email) {
    return _tentar(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  @override
  Future<bool> entrarComGoogle() async {
    try {
      await _auth.signInWithProvider(GoogleAuthProvider());
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled' || e.code == 'popup-closed-by-user') {
        return false;
      }
      throw AuthFalha(mensagemDoErro(e.code));
    }
  }

  @override
  Future<void> atualizarNome(String nome) {
    return _tentar(() async {
      await _auth.currentUser?.updateDisplayName(nome.trim());
      await _auth.currentUser?.reload();
    });
  }

  @override
  Future<void> excluirConta() {
    return _tentar(() async => _auth.currentUser?.delete());
  }

  @override
  Future<void> sair() => _auth.signOut();
}

/// Traduz o código de erro do Firebase para uma frase que o usuário entende.
String mensagemDoErro(String codigo) {
  switch (codigo) {
    case 'invalid-email':
      return 'Esse e-mail não parece válido.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'user-disabled':
      return 'Essa conta foi desativada.';
    case 'email-already-in-use':
      return 'Já existe uma conta com esse e-mail.';
    case 'weak-password':
      return 'A senha é fraca. Use pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Sem conexão com a internet. Tente de novo quando estiver online.';
    case 'too-many-requests':
      return 'Muitas tentativas. Espere um pouco e tente de novo.';
    case 'requires-recent-login':
      return 'Por segurança, saia da conta, entre de novo e repita a ação.';
    case 'operation-not-allowed':
      return 'Esse tipo de login ainda não está ativado no Firebase.';
    default:
      return 'Não foi possível concluir. Tente de novo.';
  }
}

/// Usado quando o Firebase não foi configurado: o app abre normalmente
/// e o login avisa que está indisponível.
class AuthIndisponivel implements AuthRepositorio {
  const AuthIndisponivel();

  static const _falha = AuthFalha('O login não está configurado neste aparelho. Você pode usar o app sem conta.');

  @override
  bool get disponivel => false;

  @override
  UsuarioConta? get atual => null;

  @override
  Stream<UsuarioConta?> get mudancas => const Stream.empty();

  @override
  Future<void> entrar(String email, String senha) => throw _falha;

  @override
  Future<void> criarConta({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  }) =>
      throw _falha;

  @override
  Future<void> redefinirSenha(String email) => throw _falha;

  @override
  Future<bool> entrarComGoogle() => throw _falha;

  @override
  Future<void> atualizarNome(String nome) => throw _falha;

  @override
  Future<void> excluirConta() => throw _falha;

  @override
  Future<void> sair() async {}
}
