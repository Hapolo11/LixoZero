import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/validadores.dart';
import '../services/auth_repositorio.dart';
import '../state/auth_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

enum _Modo { entrar, criar, recuperar }

/// Login opcional, com as três telas do protótipo (entrar, criar conta e
/// recuperar senha) e o botão "Não quero fazer login".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _sobrenome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  _Modo _modo = _Modo.entrar;
  bool _ocupado = false;
  bool _verSenha = false;
  String? _erro;

  @override
  void dispose() {
    for (final c in [_nome, _sobrenome, _email, _senha, _confirmacao]) {
      c.dispose();
    }
    super.dispose();
  }

  void _trocarModo(_Modo modo) {
    setState(() {
      _modo = modo;
      _erro = null;
      _senha.clear();
      _confirmacao.clear();
    });
    _form.currentState?.reset();
  }

  /// Roda uma ação de login mostrando "carregando" e o erro, se houver.
  Future<void> _executar(Future<void> Function(AuthModel auth) acao) async {
    final auth = context.read<AuthModel>();
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    try {
      await acao(auth);
    } on AuthFalha catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não foi possível concluir. Tente de novo.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _enviar() {
    if (!(_form.currentState?.validate() ?? false)) return;
    switch (_modo) {
      case _Modo.entrar:
        _executar((auth) => auth.entrar(_email.text, _senha.text));
      case _Modo.criar:
        _executar(
          (auth) => auth.criarConta(
            nome: _nome.text,
            sobrenome: _sobrenome.text,
            email: _email.text,
            senha: _senha.text,
          ),
        );
      case _Modo.recuperar:
        _executar((auth) async {
          await auth.redefinirSenha(_email.text);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enviamos um link para o seu e-mail. Veja também a caixa de spam.')),
          );
          _trocarModo(_Modo.entrar);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final disponivel = auth.loginDisponivel;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: Mascote(Pose.acenando, tamanho: 120)),
                    const SizedBox(height: 8),
                    Text(
                      _titulo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitulo,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    if (!disponivel) const _AvisoIndisponivel(),
                    ..._campos(),
                    if (_erro != null) _MensagemErro(_erro!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _ocupado || !disponivel ? null : _enviar,
                      child: _ocupado
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_rotuloBotao),
                    ),
                    ..._atalhos(),
                    if (_modo != _Modo.recuperar) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _ocupado || !disponivel
                            ? null
                            : () => _executar((auth) async {
                                  await auth.entrarComGoogle();
                                }),
                        icon: const Icon(Icons.account_circle_outlined),
                        label: const Text('Continuar com Google'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _ocupado ? null : () => auth.continuarSemLogin(),
                      icon: const Icon(Icons.person_off_outlined),
                      label: const Text('Não quero fazer login'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O app inteiro funciona sem conta.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _titulo => switch (_modo) {
        _Modo.entrar => 'Entrar',
        _Modo.criar => 'Criar conta',
        _Modo.recuperar => 'Recuperar senha',
      };

  String get _subtitulo => switch (_modo) {
        _Modo.entrar => 'Entre para guardar seus dados na sua conta.',
        _Modo.criar => 'Só pedimos o mínimo: nome, sobrenome e e-mail.',
        _Modo.recuperar => 'Se o e-mail não chegar na caixa principal, veja a caixa de spam.',
      };

  String get _rotuloBotao => switch (_modo) {
        _Modo.entrar => 'Entrar',
        _Modo.criar => 'Criar conta',
        _Modo.recuperar => 'Enviar link',
      };

  Widget _campo({
    required TextEditingController controller,
    required String rotulo,
    required String? Function(String?) validador,
    TextInputType? teclado,
    bool senha = false,
    TextInputAction acao = TextInputAction.next,
    List<String>? dicas,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !_ocupado,
        keyboardType: teclado,
        obscureText: senha && !_verSenha,
        textInputAction: acao,
        autofillHints: dicas,
        validator: validador,
        onFieldSubmitted: acao == TextInputAction.done ? (_) => _enviar() : null,
        decoration: InputDecoration(
          labelText: rotulo,
          suffixIcon: senha
              ? IconButton(
                  tooltip: _verSenha ? 'Esconder a senha' : 'Mostrar a senha',
                  icon: Icon(_verSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _verSenha = !_verSenha),
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _campos() {
    switch (_modo) {
      case _Modo.entrar:
        return [
          _campo(
            controller: _email,
            rotulo: 'E-mail',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            dicas: const [AutofillHints.email],
          ),
          _campo(
            controller: _senha,
            rotulo: 'Senha',
            validador: validarSenhaEntrada,
            senha: true,
            acao: TextInputAction.done,
            dicas: const [AutofillHints.password],
          ),
        ];
      case _Modo.criar:
        return [
          _campo(
            controller: _nome,
            rotulo: 'Nome',
            validador: (v) => validarNome(v),
            dicas: const [AutofillHints.givenName],
          ),
          _campo(
            controller: _sobrenome,
            rotulo: 'Sobrenome',
            validador: (v) => validarNome(v, campo: 'sobrenome'),
            dicas: const [AutofillHints.familyName],
          ),
          _campo(
            controller: _email,
            rotulo: 'E-mail',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            dicas: const [AutofillHints.email],
          ),
          _campo(controller: _senha, rotulo: 'Crie sua senha', validador: validarSenhaNova, senha: true),
          _campo(
            controller: _confirmacao,
            rotulo: 'Confirme sua senha',
            validador: (v) => validarConfirmacao(v, _senha.text),
            senha: true,
            acao: TextInputAction.done,
          ),
        ];
      case _Modo.recuperar:
        return [
          _campo(
            controller: _email,
            rotulo: 'E-mail',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            acao: TextInputAction.done,
          ),
        ];
    }
  }

  List<Widget> _atalhos() {
    TextButton atalho(String texto, _Modo destino) => TextButton(
          onPressed: _ocupado ? null : () => _trocarModo(destino),
          child: Text(texto),
        );

    switch (_modo) {
      case _Modo.entrar:
        return [atalho('Não possui conta? Criar conta', _Modo.criar), atalho('Esqueceu a senha?', _Modo.recuperar)];
      case _Modo.criar:
        return [atalho('Já tenho conta', _Modo.entrar)];
      case _Modo.recuperar:
        return [atalho('Voltar para o login', _Modo.entrar)];
    }
  }
}

class _MensagemErro extends StatelessWidget {
  const _MensagemErro(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 18, color: Color(0xFFB3261E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(texto, style: const TextStyle(fontSize: 13, color: Color(0xFFB3261E), height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoIndisponivel extends StatelessWidget {
  const _AvisoIndisponivel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.verdeClaro, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.verdeEscuro),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'O login não está disponível neste aparelho. Toque em "Não quero fazer login" para usar o app.',
              style: TextStyle(fontSize: 13, color: AppColors.texto, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
