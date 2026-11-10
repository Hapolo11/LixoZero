/// Dados mínimos da conta opcional (nome, sobrenome e e-mail, como no CRUD).
class UsuarioConta {
  const UsuarioConta({required this.uid, required this.email, this.nome});

  final String uid;
  final String email;
  final String? nome;

  /// O nome salvo na conta; se não tiver (ex.: conta antiga), usa a parte do
  /// e-mail antes do @.
  String get nomeExibicao {
    final salvo = nome?.trim();
    if (salvo != null && salvo.isNotEmpty) return salvo;
    final antesDoArroba = email.split('@').first.trim();
    return antesDoArroba.isEmpty ? 'Sem nome' : antesDoArroba;
  }
}

/// Erro de autenticação já com a mensagem pronta para mostrar ao usuário.
class AuthFalha implements Exception {
  const AuthFalha(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Contrato do login. O app só conversa com isto; quem fala com o Firebase
/// é o [AuthFirebase], e os testes usam uma versão falsa.
abstract class AuthRepositorio {
  /// false quando o Firebase não foi configurado neste aparelho.
  /// O app continua funcionando sem conta.
  bool get disponivel;

  UsuarioConta? get atual;

  Stream<UsuarioConta?> get mudancas;

  Future<void> entrar(String email, String senha);

  Future<void> criarConta({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  });

  /// O Firebase envia um link de redefinição para o e-mail.
  Future<void> redefinirSenha(String email);

  /// Devolve false se o usuário fechou a janela do Google sem escolher.
  Future<bool> entrarComGoogle();

  Future<void> atualizarNome(String nome);

  Future<void> excluirConta();

  Future<void> sair();
}
