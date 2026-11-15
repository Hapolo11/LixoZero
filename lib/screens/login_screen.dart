import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/validadores.dart';
import '../services/auth_repositorio.dart';
import '../state/auth_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

enum _Modo { entrar, criar, recuperar }

// As telas de login do protótipo usam Inter.
const _fonte = fonteNumeros;

/// Login opcional, igual ao protótipo de alta fidelidade: entrar, criar conta
/// e recuperar senha, com o botão "Não quero fazer login".
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
    final podeAgir = !_ocupado && disponivel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _modo == _Modo.entrar
                            ? null
                            : IconButton(
                                tooltip: 'Voltar',
                                icon: const Icon(Icons.arrow_back, color: AppColors.texto),
                                onPressed: _ocupado ? null : () => _trocarModo(_Modo.entrar),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(child: Mascote(Pose.acenando, tamanho: 150)),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!disponivel) const _AvisoIndisponivel(),
                          if (_modo == _Modo.recuperar) const _TextoRecuperar(),
                          ..._campos(),
                          if (_erro != null) _MensagemErro(_erro!),
                          const SizedBox(height: 4),
                          Center(
                            child: FilledButton(
                              style: _estiloBotao(),
                              onPressed: podeAgir ? _enviar : null,
                              child: _ocupado
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_rotuloBotao),
                            ),
                          ),
                          ..._atalhos(),
                          if (_modo != _Modo.recuperar) ...[
                            const SizedBox(height: 20),
                            Center(
                              child: _BotaoGoogle(
                                onPressed: podeAgir
                                    ? () => _executar((auth) async {
                                          await auth.entrarComGoogle();
                                        })
                                    : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (_modo == _Modo.entrar) const SizedBox(height: 28),
                    if (_modo == _Modo.criar)
                      const SizedBox(height: 32)
                    else
                      _Rodape(
                        botao: _modo == _Modo.entrar
                            ? FilledButton.icon(
                                style: _estiloBotao(largura: 270, altura: 50),
                                onPressed: _ocupado ? null : () => auth.continuarSemLogin(),
                                icon: const Icon(Icons.no_accounts_outlined, size: 22),
                                label: const Text('Não quero fazer login'),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão pequeno do protótipo. A cor é o verde escuro do justificativas.md
  /// (o texto branco no verde claro não passa no contraste).
  ButtonStyle _estiloBotao({double largura = 0, double altura = 46}) {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.verdeEscuro,
      foregroundColor: Colors.white,
      minimumSize: Size(largura, altura),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      elevation: 2,
      textStyle: const TextStyle(fontFamily: _fonte, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  String get _rotuloBotao => switch (_modo) {
        _Modo.entrar => 'Entrar',
        _Modo.criar => 'Criar conta',
        _Modo.recuperar => 'Enviar link',
      };

  Widget _campo({
    required TextEditingController controller,
    required String dica,
    required String? Function(String?) validador,
    TextInputType? teclado,
    bool senha = false,
    TextInputAction acao = TextInputAction.next,
    List<String>? dicas,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label: dica.replaceAll('.', ''),
        child: TextFormField(
          controller: controller,
          enabled: !_ocupado,
          keyboardType: teclado,
          obscureText: senha,
          textInputAction: acao,
          autofillHints: dicas,
          validator: validador,
          onFieldSubmitted: acao == TextInputAction.done ? (_) => _enviar() : null,
          style: const TextStyle(fontFamily: _fonte, fontSize: 16, color: AppColors.texto),
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(fontFamily: _fonte, fontSize: 16, color: AppColors.textoApoio),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: _borda(AppColors.verdeMedio),
            border: _borda(AppColors.verdeMedio),
            focusedBorder: _borda(AppColors.verdeEscuro),
            errorBorder: _borda(const Color(0xFFB3261E)),
            focusedErrorBorder: _borda(const Color(0xFFB3261E)),
            disabledBorder: _borda(AppColors.borda),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _borda(Color cor) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cor, width: 2),
      );

  List<Widget> _campos() {
    switch (_modo) {
      case _Modo.entrar:
        return [
          _campo(
            controller: _email,
            dica: 'Digite seu E-mail.',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            dicas: const [AutofillHints.email],
          ),
          _campo(
            controller: _senha,
            dica: 'Digite sua senha.',
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
            dica: 'Digite seu nome.',
            validador: (v) => validarNome(v),
            dicas: const [AutofillHints.givenName],
          ),
          _campo(
            controller: _sobrenome,
            dica: 'Digite seu sobrenome.',
            validador: (v) => validarNome(v, campo: 'sobrenome'),
            dicas: const [AutofillHints.familyName],
          ),
          _campo(
            controller: _email,
            dica: 'Digite seu E-mail.',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            dicas: const [AutofillHints.email],
          ),
          _campo(controller: _senha, dica: 'Crie sua senha.', validador: validarSenhaNova, senha: true),
          _campo(
            controller: _confirmacao,
            dica: 'Confirme sua senha.',
            validador: (v) => validarConfirmacao(v, _senha.text),
            senha: true,
            acao: TextInputAction.done,
          ),
        ];
      case _Modo.recuperar:
        return [
          _campo(
            controller: _email,
            dica: 'Digite seu E-mail.',
            validador: validarEmail,
            teclado: TextInputType.emailAddress,
            acao: TextInputAction.done,
          ),
        ];
    }
  }

  List<Widget> _atalhos() {
    Widget atalho(String texto, _Modo destino) => TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.texto,
            minimumSize: const Size(0, 40),
            textStyle: const TextStyle(fontFamily: _fonte, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          onPressed: _ocupado ? null : () => _trocarModo(destino),
          child: Text(texto),
        );

    if (_modo != _Modo.entrar) return const [];
    return [
      const SizedBox(height: 6),
      Center(child: atalho('Não possui conta?', _Modo.criar)),
      Center(child: atalho('Esqueceu a senha?', _Modo.recuperar)),
    ];
  }
}

/// Faixa verde curva do fim da tela, com o botão "Não quero fazer login" por cima.
class _Rodape extends StatelessWidget {
  const _Rodape({this.botao});

  final Widget? botao;

  static const _altura = 210.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _altura,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _OndaPainter())),
          if (botao != null) Positioned(top: 0, left: 0, right: 0, child: Center(child: botao)),
        ],
      ),
    );
  }
}

class _OndaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Verde mais baixo no centro e mais alto nas laterais, como no protótipo.
    final topo = h * 0.32;
    final caminho = Path()
      ..moveTo(0, topo)
      ..quadraticBezierTo(w / 2, topo + h * 0.62, w, topo - h * 0.04)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(caminho, const Color(0xFF8A93B5), 10, false);
    canvas.drawPath(caminho, Paint()..color = AppColors.verdeMedio);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BotaoGoogle extends StatelessWidget {
  const _BotaoGoogle({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(image: AssetImage('assets/images/google_g.png'), width: 26, height: 26, excludeFromSemantics: true),
                SizedBox(width: 14),
                Flexible(
                  child: Text(
                    'Continuar com Google',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _fonte,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textoApoio,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextoRecuperar extends StatelessWidget {
  const _TextoRecuperar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Text(
        'Se o e-mail não estiver na caixa principal, verifique a caixa de spam.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: _fonte, fontSize: 15, color: AppColors.texto, height: 1.4),
      ),
    );
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
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 18, color: Color(0xFFB3261E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(fontFamily: _fonte, fontSize: 13, color: Color(0xFFB3261E), height: 1.4),
              ),
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
              style: TextStyle(fontFamily: _fonte, fontSize: 13, color: AppColors.texto, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
