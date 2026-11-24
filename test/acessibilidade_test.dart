import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/app.dart';
import 'package:lixozero/data/conteudo_repository.dart';
import 'package:lixozero/data/guia_repository.dart';
import 'package:lixozero/data/lembretes_repository.dart';
import 'package:lixozero/data/pontos_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/data/rotulos_repository.dart';
import 'package:lixozero/screens/compostagem_screen.dart';
import 'package:lixozero/screens/conta_screen.dart';
import 'package:lixozero/services/localizacao_service.dart';
import 'package:lixozero/services/reconhecimento_imagem.dart';
import 'package:lixozero/state/auth_model.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/dicas_model.dart';
import 'package:lixozero/state/lembretes_model.dart';
import 'package:lixozero/state/navegacao_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/state/sincronizacao_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'busca_por_foto_test.dart' show ReconhecedorFalso, SeletorFalso;
import 'login_test.dart' show AuthFalso;
import 'notificacoes_falsas.dart';
import 'nuvem_falsa.dart';

/// Sem internet: o mapa do Google (que não roda em teste) dá lugar ao aviso,
/// e a lista de pontos continua na tela.
class _SemInternet extends ConexaoModel {
  @override
  bool get online => false;
}

/// GPS que não responde, sem chamar o plugin do aparelho.
class _LocalizacaoFalsa extends LocalizacaoService {
  @override
  Future<({Posicao? posicao, FalhaLocalizacao? falha})> posicaoAtual() async =>
      (posicao: null, falha: FalhaLocalizacao.semPermissao);

  @override
  Future<void> abrirConfiguracoes(FalhaLocalizacao falha) async {}
}

/// Confere as telas com as regras de acessibilidade do Flutter (RNF09, RNF12):
/// área de toque de 48 dp, botões com nome para o leitor de tela, contraste
/// de 4,5:1 e fonte do sistema no máximo sem quebrar o layout.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GuiaRepository guia;
  late PontosRepository pontos;
  late ConteudoRepository conteudo;
  late RotulosRepository rotulos;

  setUpAll(() async {
    guia = await GuiaRepository.carregar();
    pontos = await PontosRepository.carregar();
    conteudo = await ConteudoRepository.carregar();
    rotulos = await RotulosRepository.carregar();
  });

  /// Monta o app inteiro, com conta (logado) ou na tela de login.
  Future<AuthFalso> montar(WidgetTester tester, {bool logado = true, double escala = 1}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authRepo = AuthFalso();
    if (logado) await authRepo.entrar('ana@exemplo.com', '123456');
    final auth = AuthModel(authRepo, prefs);
    final conexao = _SemInternet();
    final nuvem = NuvemFalsa();
    final reciclagem = ReciclagemModel(ReciclagemRepository(prefs), nuvem);
    final lembretes = LembretesModel(LembretesRepository(prefs), NotificacoesFalsas(), nuvem);
    await lembretes.criar(hora: 19, minuto: 30, titulo: 'Coleta seletiva', dias: {DateTime.tuesday});
    await reciclagem.registrar('Garrafa PET', 0.03);

    // Tela de celular comum (360 x 780 dp).
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = escala;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: guia),
          Provider.value(value: pontos),
          Provider.value(value: conteudo),
          Provider.value(value: rotulos),
          Provider<ReconhecedorImagem>.value(value: ReconhecedorFalso()),
          Provider<SeletorFoto>.value(value: SeletorFalso()),
          Provider<LocalizacaoService>.value(value: _LocalizacaoFalsa()),
          ChangeNotifierProvider<ConexaoModel>.value(value: conexao),
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: reciclagem),
          ChangeNotifierProvider.value(value: lembretes),
          ChangeNotifierProvider(create: (_) => DicasModel(conteudo.dicas)),
          ChangeNotifierProvider(
            create: (_) =>
                SincronizacaoModel(auth: auth, conexao: conexao, reciclagem: reciclagem, lembretes: lembretes),
          ),
          ChangeNotifierProvider(create: (_) => NavegacaoModel()),
        ],
        child: const LixoZeroApp(),
      ),
    );
    await tester.pumpAndSettle();
    return authRepo;
  }

  Future<void> conferirRegras(WidgetTester tester) async {
    final semantica = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantica.dispose();
  }

  Future<void> abrirAba(WidgetTester tester, String nome) async {
    await tester.tap(find.text(nome).last);
    await tester.pumpAndSettle();
  }

  Future<void> buscar(WidgetTester tester, String termo) async {
    await tester.enterText(find.byType(TextField).first, termo);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  group('regras de acessibilidade', () {
    testWidgets('tela de login', (tester) async {
      await montar(tester, logado: false);
      await conferirRegras(tester);
    });

    testWidgets('Buscar, vazia e com resultado', (tester) async {
      await montar(tester);
      await conferirRegras(tester);
      await buscar(tester, 'garrafa pet');
      await conferirRegras(tester);
    });

    testWidgets('Mapa sem internet', (tester) async {
      await montar(tester);
      await abrirAba(tester, 'Mapa');
      await conferirRegras(tester);
    });

    testWidgets('Impacto com lembrete', (tester) async {
      await montar(tester);
      await abrirAba(tester, 'Impacto');
      await conferirRegras(tester);
    });

    testWidgets('Categorias', (tester) async {
      await montar(tester);
      await abrirAba(tester, 'Categoria');
      await conferirRegras(tester);
    });

    testWidgets('Compostagem', (tester) async {
      await montar(tester);
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .push(MaterialPageRoute<void>(builder: (_) => const CompostagemScreen()));
      await tester.pumpAndSettle();
      await conferirRegras(tester);
    });

    testWidgets('Conta', (tester) async {
      await montar(tester);
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .push(MaterialPageRoute<void>(builder: (_) => const ContaScreen()));
      await tester.pumpAndSettle();
      await conferirRegras(tester);
    });
  });

  /// Falha mostrando qual widget estourou, e não só "overflowed".
  void semErro(WidgetTester tester) {
    final erro = tester.takeException();
    expect(erro, isNull, reason: erro is FlutterError ? erro.toStringDeep() : '$erro');
  }

  group('fonte do sistema em 200% sem quebrar o layout', () {
    testWidgets('nomes das abas ficam numa linha só', (tester) async {
      await montar(tester, escala: 2);
      for (final nome in ['Buscar', 'Mapa', 'Impacto', 'Categoria']) {
        final texto = tester.renderObject<RenderParagraph>(find.text(nome).last);
        expect(texto.didExceedMaxLines, isFalse, reason: nome);
        expect(texto.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: nome.length)).length, 1,
            reason: '"$nome" quebrou em mais de uma linha');
      }
    });

    Future<void> rolarTudo(WidgetTester tester) async {
      final rolaveis = find.byType(Scrollable);
      for (var i = 0; i < rolaveis.evaluate().length; i++) {
        final r = rolaveis.at(i);
        final estado = tester.state<ScrollableState>(r);
        if (estado.position.axis != Axis.vertical) continue;
        estado.position.jumpTo(estado.position.maxScrollExtent);
        await tester.pumpAndSettle();
      }
    }

    testWidgets('login', (tester) async {
      await montar(tester, logado: false, escala: 2);
      semErro(tester);
      await rolarTudo(tester);
      semErro(tester);
    });

    for (final aba in ['Buscar', 'Mapa', 'Impacto', 'Categoria']) {
      testWidgets(aba, (tester) async {
        await montar(tester, escala: 2);
        if (aba != 'Buscar') await abrirAba(tester, aba);
        if (aba == 'Buscar') await buscar(tester, 'garrafa pet');
        semErro(tester);
        await rolarTudo(tester);
        semErro(tester);
      });
    }

    testWidgets('Compostagem e Conta', (tester) async {
      await montar(tester, escala: 2);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(MaterialPageRoute<void>(builder: (_) => const CompostagemScreen()));
      await tester.pumpAndSettle();
      await rolarTudo(tester);
      semErro(tester);
      nav.pop();
      await tester.pumpAndSettle();
      nav.push(MaterialPageRoute<void>(builder: (_) => const ContaScreen()));
      await tester.pumpAndSettle();
      await rolarTudo(tester);
      semErro(tester);
    });
  });
}
