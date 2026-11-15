import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/validadores.dart';
import 'package:lixozero/screens/login_screen.dart';
import 'package:lixozero/services/auth_firebase.dart';
import 'package:lixozero/services/auth_repositorio.dart';
import 'package:lixozero/state/auth_model.dart';
import 'package:lixozero/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Login de mentira, para testar o app sem o Firebase.
class AuthFalso implements AuthRepositorio {
  AuthFalso({this.disponivel = true});

  @override
  final bool disponivel;

  final _controle = StreamController<UsuarioConta?>.broadcast();
  UsuarioConta? _usuario;
  String? falhaProximaChamada;
  final chamadas = <String>[];

  @override
  UsuarioConta? get atual => _usuario;

  @override
  Stream<UsuarioConta?> get mudancas => _controle.stream;

  void _definir(UsuarioConta? u) {
    _usuario = u;
    _controle.add(u);
  }

  void _verificarFalha() {
    final falha = falhaProximaChamada;
    if (falha != null) {
      falhaProximaChamada = null;
      throw AuthFalha(falha);
    }
  }

  @override
  Future<void> entrar(String email, String senha) async {
    chamadas.add('entrar');
    _verificarFalha();
    _definir(UsuarioConta(uid: '1', email: email, nome: 'Ana Souza'));
  }

  @override
  Future<void> criarConta({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  }) async {
    chamadas.add('criarConta');
    _verificarFalha();
    _definir(UsuarioConta(uid: '1', email: email, nome: '$nome $sobrenome'));
  }

  @override
  Future<void> redefinirSenha(String email) async {
    chamadas.add('redefinirSenha');
    _verificarFalha();
  }

  @override
  Future<bool> entrarComGoogle() async {
    chamadas.add('google');
    _verificarFalha();
    _definir(const UsuarioConta(uid: '2', email: 'g@gmail.com', nome: 'Google'));
    return true;
  }

  @override
  Future<void> atualizarNome(String nome) async {
    _definir(UsuarioConta(uid: _usuario!.uid, email: _usuario!.email, nome: nome));
  }

  @override
  Future<void> excluirConta() async {
    chamadas.add('excluir');
    _definir(null);
  }

  @override
  Future<void> sair() async {
    chamadas.add('sair');
    _definir(null);
  }
}

Future<AuthModel> _criarModelo(AuthFalso repo, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AuthModel(repo, await SharedPreferences.getInstance());
}

void main() {
  group('validadores', () {
    test('e-mail', () {
      expect(validarEmail(''), isNotNull);
      expect(validarEmail('ana'), isNotNull);
      expect(validarEmail('ana@email'), isNotNull);
      expect(validarEmail(' ana@email.com '), isNull);
    });

    test('senha nova precisa de 6 caracteres e a confirmação tem que bater', () {
      expect(validarSenhaNova('12345'), isNotNull);
      expect(validarSenhaNova('123456'), isNull);
      expect(validarConfirmacao('123457', '123456'), isNotNull);
      expect(validarConfirmacao('123456', '123456'), isNull);
    });

    test('nome e sobrenome', () {
      expect(validarNome(' '), 'Digite seu nome.');
      expect(validarNome('', campo: 'sobrenome'), 'Digite seu sobrenome.');
      expect(validarNome('Ana'), isNull);
    });
  });

  test('sem nome salvo, o perfil mostra o começo do e-mail', () {
    expect(const UsuarioConta(uid: '1', email: 'ana.souza@email.com').nomeExibicao, 'ana.souza');
    expect(const UsuarioConta(uid: '1', email: 'ana@email.com', nome: '  ').nomeExibicao, 'ana');
    expect(const UsuarioConta(uid: '1', email: 'ana@email.com', nome: 'Ana Souza').nomeExibicao, 'Ana Souza');
  });

  test('mensagens de erro do Firebase estão em português', () {
    expect(mensagemDoErro('wrong-password'), 'E-mail ou senha incorretos.');
    expect(mensagemDoErro('email-already-in-use'), contains('Já existe'));
    expect(mensagemDoErro('network-request-failed'), contains('internet'));
    expect(mensagemDoErro('qualquer-outro'), contains('Tente de novo'));
  });

  group('AuthModel', () {
    test('começa pedindo a escolha e lembra do "Não quero fazer login"', () async {
      final modelo = await _criarModelo(AuthFalso());
      expect(modelo.sessao, Sessao.precisaEscolher);

      await modelo.continuarSemLogin();
      expect(modelo.sessao, Sessao.visitante);

      final outro = AuthModel(AuthFalso(), await SharedPreferences.getInstance());
      expect(outro.sessao, Sessao.visitante, reason: 'a escolha fica salva no aparelho');
    });

    test('entrar e sair', () async {
      final repo = AuthFalso();
      final modelo = await _criarModelo(repo);

      await modelo.entrar('ana@email.com', '123456');
      expect(modelo.sessao, Sessao.logado);
      expect(modelo.usuario?.email, 'ana@email.com');

      await modelo.sair();
      expect(modelo.sessao, Sessao.precisaEscolher);
    });

    test('visitante pode voltar para o login', () async {
      final modelo = await _criarModelo(AuthFalso(), prefs: {'visitante': true});
      expect(modelo.sessao, Sessao.visitante);

      await modelo.pedirLogin();
      expect(modelo.sessao, Sessao.precisaEscolher);
    });

    test('editar nome e excluir conta', () async {
      final modelo = await _criarModelo(AuthFalso());
      await modelo.criarConta(nome: 'Ana', sobrenome: 'Souza', email: 'a@b.com', senha: '123456');
      expect(modelo.usuario?.nome, 'Ana Souza');

      await modelo.atualizarNome('Ana Maria');
      expect(modelo.usuario?.nome, 'Ana Maria');

      await modelo.excluirConta();
      expect(modelo.usuario, isNull);
      expect(modelo.sessao, Sessao.precisaEscolher);
    });

    test('falha no login não deixa o usuário logado', () async {
      final repo = AuthFalso()..falhaProximaChamada = 'E-mail ou senha incorretos.';
      final modelo = await _criarModelo(repo);

      await expectLater(modelo.entrar('a@b.com', 'errada'), throwsA(isA<AuthFalha>()));
      expect(modelo.sessao, Sessao.precisaEscolher);
    });
  });

  group('tela de login', () {
    Future<(AuthFalso, AuthModel)> abrir(WidgetTester tester, {bool disponivel = true}) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final repo = AuthFalso(disponivel: disponivel);
      final modelo = await _criarModelo(repo);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: modelo,
          child: MaterialApp(theme: criarTema(), home: const LoginScreen()),
        ),
      );
      return (repo, modelo);
    }

    testWidgets('"Não quero fazer login" libera o app sem conta', (tester) async {
      final (repo, modelo) = await abrir(tester);

      await tester.tap(find.text('Não quero fazer login'));
      await tester.pump();

      expect(modelo.sessao, Sessao.visitante);
      expect(repo.chamadas, isEmpty);
    });

    testWidgets('campos vazios mostram os erros e não chamam o login', (tester) async {
      final (repo, _) = await abrir(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Digite seu e-mail.'), findsOneWidget);
      expect(find.text('Digite sua senha.'), findsOneWidget);
      expect(repo.chamadas, isEmpty);
    });

    testWidgets('entrar com e-mail e senha', (tester) async {
      final (repo, modelo) = await abrir(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(repo.chamadas, ['entrar']);
      expect(modelo.sessao, Sessao.logado);
    });

    testWidgets('erro do login aparece na tela', (tester) async {
      final (repo, modelo) = await abrir(tester);
      repo.falhaProximaChamada = 'E-mail ou senha incorretos.';

      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'errada');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(modelo.sessao, Sessao.precisaEscolher);
    });

    testWidgets('criar conta confere se as senhas são iguais', (tester) async {
      final (repo, _) = await abrir(tester);

      await tester.tap(find.text('Não possui conta? Criar conta'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sobrenome'), 'Souza');
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Crie sua senha'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirme sua senha'), '654321');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pump();

      expect(find.text('As senhas não são iguais.'), findsOneWidget);
      expect(repo.chamadas, isEmpty);
    });

    testWidgets('e-mail que já tem conta mostra o aviso ao criar conta', (tester) async {
      final (repo, modelo) = await abrir(tester);
      repo.falhaProximaChamada = mensagemDoErro('email-already-in-use');

      await tester.tap(find.text('Não possui conta? Criar conta'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sobrenome'), 'Souza');
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'ana@email.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Crie sua senha'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirme sua senha'), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Já existe uma conta com esse e-mail.'), findsOneWidget);
      expect(modelo.sessao, Sessao.precisaEscolher);
    });

    testWidgets('sem Firebase o login fica desativado, mas dá para seguir sem conta', (tester) async {
      final (_, modelo) = await abrir(tester, disponivel: false);

      expect(find.textContaining('não está disponível'), findsOneWidget);
      final entrar = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Entrar'));
      expect(entrar.onPressed, isNull);

      await tester.tap(find.text('Não quero fazer login'));
      await tester.pump();
      expect(modelo.sessao, Sessao.visitante);
    });
  });
}
