import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/conteudo_repository.dart';
import 'package:lixozero/data/guia_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/data/rotulos_repository.dart';
import 'package:lixozero/screens/buscar_screen.dart';
import 'package:lixozero/services/reconhecimento_imagem.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/dicas_model.dart';
import 'package:lixozero/state/navegacao_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dicas_falsas.dart';

/// Câmera e galeria de mentira: devolve uma foto fixa (ou nada, ou um erro).
class SeletorFalso implements SeletorFoto {
  String? caminho = 'foto.jpg';
  Object? erro;
  OrigemFoto? ultimaOrigem;

  @override
  Future<String?> escolher(OrigemFoto origem) async {
    ultimaOrigem = origem;
    final falha = erro;
    if (falha != null) throw falha;
    return caminho;
  }
}

/// Reconhecimento de mentira: devolve os rótulos combinados no teste.
class ReconhecedorFalso implements ReconhecedorImagem {
  List<RotuloImagem> rotulos = const [];
  Object? erro;
  final fotosAnalisadas = <String>[];

  @override
  Future<List<RotuloImagem>> reconhecer(String caminhoDaFoto) async {
    fotosAnalisadas.add(caminhoDaFoto);
    final falha = erro;
    if (falha != null) throw falha;
    return rotulos;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GuiaRepository guia;
  late ConteudoRepository conteudo;
  late RotulosRepository rotulos;

  setUpAll(() async {
    guia = await GuiaRepository.carregar();
    conteudo = await ConteudoRepository.carregar();
    rotulos = await RotulosRepository.carregar();
  });

  group('rotulos.json', () {
    test('todo item citado existe no guia', () {
      final ids = guia.itens.map((i) => i.id).toSet();
      final inexistentes = <String>[];
      rotulos.rotulos.forEach((rotulo, itens) {
        for (final id in itens) {
          if (!ids.contains(id)) inexistentes.add('$rotulo -> $id');
        }
      });
      expect(inexistentes, isEmpty, reason: 'ids que não estão em guia.json');
    });

    test('todo rótulo indica pelo menos um item e nenhum item se repete na lista', () {
      rotulos.rotulos.forEach((rotulo, itens) {
        expect(itens, isNotEmpty, reason: rotulo);
        expect(itens.toSet().length, itens.length, reason: 'itens repetidos em "$rotulo"');
      });
    });

    test('cobre as 6 categorias de resíduo do guia', () {
      final categorias = <String>{};
      final porId = {for (final i in guia.itens) i.id: i};
      for (final itens in rotulos.rotulos.values) {
        for (final id in itens) {
          categorias.add(porId[id]!.categoriaId);
        }
      }
      expect(categorias, containsAll(['plastico', 'papel', 'vidro', 'metal', 'organico', 'perigoso']));
    });
  });

  group('sugerir', () {
    List<String> ids(List<RotuloImagem> r, {int limite = 3}) =>
        rotulos.sugerir(r, guia, limite: limite).map((i) => i.id).toList();

    test('um rótulo sugere os itens dele, o mais provável primeiro', () {
      expect(ids([const RotuloImagem('Bottle', 0.9)]).first, 'garrafa_pet');
    });

    test('não diferencia maiúsculas de minúsculas', () {
      expect(ids([const RotuloImagem('bottle', 0.9)]).first, 'garrafa_pet');
      expect(ids([const RotuloImagem('  BANANA ', 0.9)]).first, 'casca_banana');
    });

    test('rótulos que se reforçam sobem na lista', () {
      // "Banana" e "Fruit" apontam para a casca de banana; só "Fruit" apontaria
      // primeiro para a casca de fruta.
      expect(ids([const RotuloImagem('Fruit', 0.7)]).first, 'casca_fruta');
      expect(
        ids([const RotuloImagem('Banana', 0.8), const RotuloImagem('Fruit', 0.7)]).first,
        'casca_banana',
      );
    });

    test('quem tem mais confiança ganha', () {
      expect(
        ids([const RotuloImagem('Newspaper', 0.6), const RotuloImagem('Plastic bag', 0.95)]).first,
        'sacola_plastica',
      );
    });

    test('respeita o limite e não repete itens', () {
      final todos = ids([const RotuloImagem('Bottle', 0.9), const RotuloImagem('Glass', 0.8)], limite: 10);
      expect(todos.toSet().length, todos.length);
      expect(ids([const RotuloImagem('Bottle', 0.9), const RotuloImagem('Glass', 0.8)], limite: 2), hasLength(2));
    });

    test('rótulos desconhecidos não sugerem nada', () {
      expect(ids([const RotuloImagem('Sky', 0.99), const RotuloImagem('Sunset', 0.9)]), isEmpty);
      expect(ids(const []), isEmpty);
    });
  });

  group('busca por foto na tela Buscar', () {
    Future<(SeletorFalso, ReconhecedorFalso)> montar(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final reciclagem = ReciclagemModel(ReciclagemRepository(await SharedPreferences.getInstance()));
      final seletor = SeletorFalso();
      final reconhecedor = ReconhecedorFalso();

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: guia),
            Provider.value(value: conteudo),
            Provider.value(value: rotulos),
            Provider<SeletorFoto>.value(value: seletor),
            Provider<ReconhecedorImagem>.value(value: reconhecedor),
            ChangeNotifierProvider(create: (_) => NavegacaoModel()),
            ChangeNotifierProvider(create: (_) => ConexaoModel()),
            ChangeNotifierProvider.value(value: reciclagem),
            ChangeNotifierProvider(create: (_) => DicasModel(dicasDeTeste)),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );
      await tester.pump();
      return (seletor, reconhecedor);
    }

    /// Procura só dentro da janela de sugestões (a tela também tem "Casca de
    /// banana" entre as dúvidas comuns).
    Finder naJanela(String texto) => find.descendant(of: find.byType(BottomSheet), matching: find.text(texto));

    Future<void> tocarCamera(WidgetTester tester, {String opcao = 'Tirar uma foto'}) async {
      await tester.tap(find.byTooltip('Buscar por foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(opcao));
      await tester.pumpAndSettle();
    }

    testWidgets('foto reconhecida: o usuário confirma e vê o resultado de sempre', (tester) async {
      final (seletor, reconhecedor) = await montar(tester);
      reconhecedor.rotulos = const [RotuloImagem('Bottle', 0.92)];

      await tocarCamera(tester);

      expect(seletor.ultimaOrigem, OrigemFoto.camera);
      expect(reconhecedor.fotosAnalisadas, ['foto.jpg']);
      expect(find.text('Parece ser um destes. Qual é?'), findsOneWidget);
      expect(naJanela('Garrafa PET'), findsOneWidget);

      await tester.tap(naJanela('Garrafa PET'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('INSTRUÇÃO DE DESCARTE'), findsWidgets, reason: 'a busca de sempre mostra os cartões');
      expect(find.widgetWithText(FilledButton, 'Registrar reciclagem'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Garrafa PET'), findsOneWidget, reason: 'o nome entra no campo de busca');
    });

    testWidgets('a galeria funciona igual à câmera', (tester) async {
      final (seletor, reconhecedor) = await montar(tester);
      reconhecedor.rotulos = const [RotuloImagem('Banana', 0.9)];

      await tocarCamera(tester, opcao: 'Escolher da galeria');

      expect(seletor.ultimaOrigem, OrigemFoto.galeria);
      expect(naJanela('Casca de banana'), findsOneWidget);
    });

    testWidgets('"Nenhum desses" fecha sem buscar nada', (tester) async {
      final (_, reconhecedor) = await montar(tester);
      reconhecedor.rotulos = const [RotuloImagem('Bottle', 0.92)];

      await tocarCamera(tester);
      await tester.tap(find.text('Nenhum desses, vou digitar'));
      await tester.pumpAndSettle();

      expect(find.text('INSTRUÇÃO DE DESCARTE'), findsNothing);
      expect(find.text('Digite o resíduo'), findsOneWidget);
    });

    testWidgets('foto não reconhecida avisa e leva para a busca por texto', (tester) async {
      final (_, reconhecedor) = await montar(tester);
      reconhecedor.rotulos = const [RotuloImagem('Sky', 0.99)];

      await tocarCamera(tester);

      expect(find.textContaining('Não reconheci esse resíduo'), findsOneWidget);
      expect(find.text('Parece ser um destes. Qual é?'), findsNothing);
      expect(find.text('INSTRUÇÃO DE DESCARTE'), findsNothing);
    });

    testWidgets('quem desiste da foto não dispara nenhuma análise', (tester) async {
      final (seletor, reconhecedor) = await montar(tester);
      seletor.caminho = null;

      await tocarCamera(tester);

      expect(reconhecedor.fotosAnalisadas, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('câmera negada mostra o aviso, sem travar a tela', (tester) async {
      final (seletor, _) = await montar(tester);
      seletor.erro = StateError('camera_access_denied');

      await tocarCamera(tester);

      expect(find.textContaining('Não foi possível abrir a câmera'), findsOneWidget);
      expect(find.text('Digite o resíduo'), findsOneWidget);
    });

    testWidgets('falha no reconhecimento mostra o aviso e fecha o "Analisando"', (tester) async {
      final (_, reconhecedor) = await montar(tester);
      reconhecedor.erro = StateError('modelo indisponível');

      await tocarCamera(tester);

      expect(find.textContaining('Não consegui analisar a foto'), findsOneWidget);
      expect(find.text('Analisando a foto...'), findsNothing);
    });
  });
}
