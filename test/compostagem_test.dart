import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/conteudo_repository.dart';
import 'package:lixozero/data/guia_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/screens/buscar_screen.dart';
import 'package:lixozero/screens/categorias_screen.dart';
import 'package:lixozero/screens/compostagem_screen.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/dicas_model.dart';
import 'package:lixozero/state/navegacao_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/theme/app_theme.dart';
import 'package:lixozero/widgets/dica_rodape.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dicas_falsas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GuiaRepository guia;
  late ConteudoRepository conteudo;

  setUpAll(() async {
    guia = await GuiaRepository.carregar();
    conteudo = await ConteudoRepository.carregar();
  });

  /// Monta uma tela com o que ela precisa do app de verdade (guia e conteúdo
  /// reais, lidos dos JSON). Devolve a navegação para conferir as abas.
  Future<NavegacaoModel> montar(WidgetTester tester, Widget tela, {DicasModel? dicas}) async {
    SharedPreferences.setMockInitialValues({});
    final reciclagem = ReciclagemModel(ReciclagemRepository(await SharedPreferences.getInstance()));
    final navegacao = NavegacaoModel();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: guia),
          Provider.value(value: conteudo),
          ChangeNotifierProvider.value(value: navegacao),
          ChangeNotifierProvider(create: (_) => ConexaoModel()),
          ChangeNotifierProvider.value(value: reciclagem),
          ChangeNotifierProvider.value(value: dicas ?? DicasModel(dicasDeTeste)),
        ],
        child: MaterialApp(theme: criarTema(), home: Scaffold(body: tela)),
      ),
    );
    await tester.pump();
    return navegacao;
  }

  Future<void> buscar(WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.tap(find.widgetWithText(FilledButton, 'Buscar'));
    await tester.pumpAndSettle();
  }

  group('RF06 - conteúdo de compostagem', () {
    test('o guia de compostagem está completo', () {
      final c = conteudo.compostagem;
      expect(c.introducao, isNotEmpty);
      expect(c.podeVerdes, isNotEmpty);
      expect(c.podeSecos, isNotEmpty);
      expect(c.naoPode, isNotEmpty);
      expect(c.passos.length, greaterThanOrEqualTo(5));
      expect(c.chorume, isNotEmpty);
      expect(c.problemas, isNotEmpty);
      expect(c.semEspaco, isNotEmpty);
      for (final p in c.naoPode) {
        expect(p.item, isNotEmpty);
        expect(p.motivo, isNotEmpty, reason: p.item);
      }
      for (final p in c.problemas) {
        expect(p.solucao, isNotEmpty, reason: p.problema);
      }
    });

    test('o guia de compostagem concorda com o guia de classificação', () {
      // A instrução de "Restos de comida" diz que carne e laticínios não vão
      // para a composteira; o guia de compostagem precisa dizer o mesmo.
      final proibidos = conteudo.compostagem.naoPode.map((p) => p.item.toLowerCase()).join(' ');
      expect(proibidos, contains('carne'));
      expect(proibidos, contains('laticínios'));
      expect(proibidos, contains('óleo'));
    });

    testWidgets('a tela mostra o que pode, o que não pode e o passo a passo', (tester) async {
      await montar(tester, const CompostagemScreen());

      expect(find.text('Compostagem em casa'), findsOneWidget);
      expect(find.text('O que pode ir'), findsOneWidget);
      expect(find.text(conteudo.compostagem.podeVerdes.first), findsOneWidget);

      await tester.scrollUntilVisible(find.text('O que não pode ir'), 300);
      expect(find.textContaining(conteudo.compostagem.naoPode.first.motivo), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Passo a passo'), 300);
      expect(find.text(conteudo.compostagem.passos.first), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Sem espaço para composteira?'), 300);
      expect(find.text(conteudo.compostagem.semEspaco), findsOneWidget);
    });

    testWidgets('a categoria Orgânico, e só ela, leva ao guia de compostagem', (tester) async {
      await montar(tester, const CategoriasScreen());

      final botao = find.text('Aprenda a compostar em casa');
      await tester.scrollUntilVisible(botao, 300);
      expect(botao, findsOneWidget);
      await tester.ensureVisible(botao); // a lista monta itens um pouco antes de aparecerem
      await tester.pumpAndSettle();

      await tester.tap(botao);
      await tester.pumpAndSettle();
      expect(find.byType(CompostagemScreen), findsOneWidget);
    });

    testWidgets('resultado orgânico tem "Como compostar"; o reciclável não', (tester) async {
      await montar(tester, const BuscarScreen());

      await buscar(tester, 'garrafa pet');
      expect(find.text('Como compostar'), findsNothing);

      await buscar(tester, 'casca de banana');
      expect(find.text('Como compostar'), findsWidgets);
      await tester.tap(find.text('Como compostar').first);
      await tester.pumpAndSettle();
      expect(find.byType(CompostagemScreen), findsOneWidget);
    });

    testWidgets('restos de comida avisa que comida cozida não vai na composteira', (tester) async {
      // O item vai para "compostagem ou lixo orgânico". O botão aparece, e a
      // instrução já avisa que comida cozida não vai na composteira caseira.
      await montar(tester, const BuscarScreen());
      await buscar(tester, 'restos de comida');
      expect(find.textContaining('não vão na composteira caseira'), findsOneWidget);
    });
  });

  group('Dicas do rodapé', () {
    test('toda dica está completa e a primeira é a do protótipo', () {
      final ids = <String>{};
      for (final d in conteudo.dicas) {
        expect(ids.add(d.id), isTrue, reason: 'id repetido: ${d.id}');
        expect(d.tema, isNotEmpty, reason: d.id);
        expect(d.titulo, isNotEmpty, reason: d.id);
        expect(d.texto, isNotEmpty, reason: d.id);
      }
      expect(conteudo.dicas.first.tema, 'compostagem');
      expect(conteudo.dicas.first.titulo, 'Restos de comida viram adubo');
    });

    test('o item de cada dica existe no guia de classificação', () {
      for (final d in conteudo.dicas.where((d) => d.busca != null)) {
        expect(guia.busca.buscar(d.busca!), isNotEmpty, reason: '${d.id}: "${d.busca}" não acha nada no guia');
      }
    });

    test('primeira abertura mostra a primeira dica; cada abertura mostra a seguinte', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final abertura1 = DicasModel(dicasDeTeste, prefs);
      await abertura1.carregar();
      expect(abertura1.atual.id, 'compostagem');

      final abertura2 = DicasModel(dicasDeTeste, prefs);
      await abertura2.carregar();
      expect(abertura2.atual.id, 'pet');

      final abertura3 = DicasModel(dicasDeTeste, prefs);
      await abertura3.carregar();
      expect(abertura3.atual.id, 'compostagem', reason: 'depois da última, volta para a primeira');
    });

    test('cada busca troca a dica, e a troca fica salva para a próxima abertura', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dicas = DicasModel(dicasDeTeste, prefs);
      await dicas.carregar();

      var avisos = 0;
      dicas.addListener(() => avisos++);
      dicas.proxima();
      expect(dicas.atual.id, 'pet');
      expect(avisos, 1);
      expect(prefs.getInt(DicasModel.chave), 1);
    });

    test('número salvo fora da lista não quebra o app', () async {
      SharedPreferences.setMockInitialValues({DicasModel.chave: 57});
      final dicas = DicasModel(dicasDeTeste, await SharedPreferences.getInstance());
      await dicas.carregar();
      expect(dicasDeTeste, contains(dicas.atual));
    });

    testWidgets('a faixa abre o cartão da dica e "Entendi" fecha', (tester) async {
      await montar(tester, const BuscarScreen());

      expect(find.text('Dica: compostagem'), findsOneWidget);
      await tester.tap(find.byKey(const Key('barra_dica')));
      await tester.pumpAndSettle();

      expect(find.byType(DialogoDica), findsOneWidget);
      expect(find.text('Restos de comida viram adubo'), findsOneWidget);
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.byType(DialogoDica), findsNothing);
    });

    testWidgets('a dica muda depois de uma busca', (tester) async {
      await montar(tester, const BuscarScreen());
      expect(find.text('Dica: compostagem'), findsOneWidget);

      await buscar(tester, 'pilha');
      expect(find.text('Dica: embalagens'), findsOneWidget);
    });

    testWidgets('dica de compostagem leva ao guia de compostagem', (tester) async {
      await montar(tester, const BuscarScreen());

      await tester.tap(find.byKey(const Key('barra_dica')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Como compostar em casa'));
      await tester.pumpAndSettle();

      expect(find.byType(CompostagemScreen), findsOneWidget);
    });

    testWidgets('dica com item faz a busca dele', (tester) async {
      final dicas = DicasModel(dicasDeTeste)..proxima(); // a dica "pet"
      final navegacao = await montar(tester, const BuscarScreen(), dicas: dicas);

      await tester.tap(find.byKey(const Key('barra_dica')));
      await tester.pumpAndSettle();
      expect(find.text('Como compostar em casa'), findsNothing);
      await tester.tap(find.text('Ver como descartar'));
      await tester.pumpAndSettle();

      expect(navegacao.aba, Aba.buscar);
      expect(find.text('Garrafa PET'), findsWidgets);
      expect(find.text('INSTRUÇÃO DE DESCARTE'), findsWidgets);
    });
  });
}
