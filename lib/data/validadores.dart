// Validações dos campos do login. Devolvem a mensagem de erro, ou null se estiver ok.

String? validarNome(String? valor, {String campo = 'nome'}) {
  if (valor == null || valor.trim().isEmpty) return 'Digite seu $campo.';
  if (valor.trim().length < 2) return 'O $campo precisa ter pelo menos 2 letras.';
  return null;
}

final _formatoEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

String? validarEmail(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Digite seu e-mail.';
  if (!_formatoEmail.hasMatch(valor.trim())) return 'Digite um e-mail válido, como nome@email.com.';
  return null;
}

String? validarSenhaEntrada(String? valor) {
  if (valor == null || valor.isEmpty) return 'Digite sua senha.';
  return null;
}

String? validarSenhaNova(String? valor) {
  if (valor == null || valor.isEmpty) return 'Crie uma senha.';
  if (valor.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
  return null;
}

String? validarConfirmacao(String? valor, String senha) {
  if (valor == null || valor.isEmpty) return 'Confirme sua senha.';
  if (valor != senha) return 'As senhas não são iguais.';
  return null;
}
