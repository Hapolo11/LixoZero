import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/guia_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/models/categoria.dart';
import 'package:lixozero/models/item_guia.dart';
import 'package:lixozero/models/registro_reciclagem.dart';
import 'package:lixozero/screens/buscar_screen.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/navegacao_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

GuiaRepository _criarGuiaFalso() {
  const categorias = [
    Categoria(
      id: 'plastico',
      nome: 'Plástico',
      lixeira: 'Lixeira Vermelha',
      cor: Color(0xFFFF2D2D),
      descricao: 'Plásticos em geral',
      exemplos: ['Garrafa PET'],
    ),
  ];
  const itens = [
    ItemGuia(
      id: 'garrafa_pet',
      nome: 'Garrafa PET',
      sinonimos: ['pet', 'refrigerante'],
      categoriaId: 'plastico',
      destino: 'coleta_seletiva',
      pesoKg: 0.03,
      instrucao: 'Enxágue e descarte no reciclável.',
    ),
  ];
  final destinos = {'coleta_seletiva': 'Coleta seletiva'};
  return GuiaRepository(categorias, itens, destinos);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RF09 - ReciclagemModel', () {
    test('registrar soma o peso médio', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final model = ReciclagemModel(repo);
      await model.carregar();

      expect(model.totalKg, 0.0);
      expect(model.registros, isEmpty);

      final r1 = await model.registrar('Garrafa PET', 0.03);
      expect(r1.item, 'Garrafa PET');
      expect(r1.pesoKg, 0.03);
      expect(model.totalKg, closeTo(0.03, 0.0001));
      expect(model.registros.length, 1);

      final r2 = await model.registrar('Lata de alumínio', 0.015);
      expect(r2.item, 'Lata de alumínio');
      expect(r2.pesoKg, 0.015);
      expect(model.totalKg, closeTo(0.045, 0.0001));
      expect(model.registros.length, 2);
    });

    test('ajustar peso atualiza o total', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final model = ReciclagemModel(repo);
      await model.carregar();

      final r = await model.registrar('Garrafa PET', 0.03);
      expect(model.totalKg, closeTo(0.03, 0.0001));

      await model.ajustarPeso(r.id, 0.05);
      expect(model.totalKg, closeTo(0.05, 0.0001));
      expect(model.registros.first.pesoKg, 0.05);

      // Valores inválidos ou menores/iguais a zero são ignorados
      await model.ajustarPeso(r.id, 0.0);
      expect(model.totalKg, closeTo(0.05, 0.0001));

      await model.ajustarPeso(r.id, -0.02);
      expect(model.totalKg, closeTo(0.05, 0.0001));

      // Id inexistente não quebra nem altera nada
      await model.ajustarPeso('inexistente', 0.2);
      expect(model.totalKg, closeTo(0.05, 0.0001));
    });

    test('os dados persistem após recarregar', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo1 = ReciclagemRepository(prefs);
      final model1 = ReciclagemModel(repo1);
      await model1.carregar();

      final r1 = await model1.registrar('Garrafa PET', 0.03);
      await model1.registrar('Jornal', 0.2);
      await model1.ajustarPeso(r1.id, 0.04);

      expect(model1.totalKg, closeTo(0.24, 0.0001));
      expect(model1.registros.length, 2);

      // Simula nova abertura do app recarregando dos SharedPreferences
      final repo2 = ReciclagemRepository(prefs);
      final model2 = ReciclagemModel(repo2);
      await model2.carregar();

      expect(model2.registros.length, 2);
      expect(model2.totalKg, closeTo(0.24, 0.0001));
      expect(model2.registros[0].id, r1.id);
      expect(model2.registros[0].item, 'Garrafa PET');
      expect(model2.registros[0].pesoKg, 0.04);
      expect(model2.registros[1].item, 'Jornal');
      expect(model2.registros[1].pesoKg, 0.2);
    });

    test('modelo RegistroReciclagem toJson e fromJson', () {
      final agora = DateTime.now();
      final registro = RegistroReciclagem(
        id: '123',
        item: 'Garrafa PET',
        pesoKg: 0.03,
        data: agora,
      );

      final json = registro.toJson();
      final reconstruido = RegistroReciclagem.fromJson(json);

      expect(reconstruido.id, '123');
      expect(reconstruido.item, 'Garrafa PET');
      expect(reconstruido.pesoKg, 0.03);
      expect(reconstruido.data.isAtSameMomentAs(agora), isTrue);
      expect(reconstruido, registro);
    });
  });

  group('RF09 - Telas e Integração', () {
    testWidgets('apenas fazer a busca NÃO registra nada', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final reciclagem = ReciclagemModel(repo);
      await reciclagem.carregar();

      final guia = _criarGuiaFalso();
      final navegacao = NavegacaoModel();
      final conexao = ConexaoModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: guia),
            ChangeNotifierProvider.value(value: navegacao),
            ChangeNotifierProvider.value(value: conexao),
            ChangeNotifierProvider.value(value: reciclagem),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Garrafa');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Garrafa PET'), findsOneWidget);
      expect(reciclagem.registros, isEmpty);
      expect(reciclagem.totalKg, 0.0);
    });

    testWidgets('botão registra reciclagem, exibe toast e ação ajustar peso atualiza o peso', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final reciclagem = ReciclagemModel(repo);
      await reciclagem.carregar();

      final guia = _criarGuiaFalso();
      final navegacao = NavegacaoModel();
      final conexao = ConexaoModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: guia),
            ChangeNotifierProvider.value(value: navegacao),
            ChangeNotifierProvider.value(value: conexao),
            ChangeNotifierProvider.value(value: reciclagem),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Garrafa');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(find.text('Registrar reciclagem'), findsOneWidget);

      // Toca no botão para registrar
      await tester.tap(find.text('Registrar reciclagem'));
      await tester.pumpAndSettle();

      // Confirma registro e SnackBar com peso real com vírgula e 2 casas
      expect(reciclagem.registros.length, 1);
      expect(reciclagem.totalKg, closeTo(0.03, 0.0001));
      expect(find.text('Registrado! +0,03 kg'), findsOneWidget);
      expect(find.text('Ajustar peso'), findsOneWidget);

      // Toca em "Ajustar peso"
      await tester.tap(find.text('Ajustar peso'));
      await tester.pumpAndSettle();

      expect(find.text('Ajustar peso'), findsWidgets); // dialog title
      expect(find.byType(AlertDialog), findsOneWidget);

      final campoDialog = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
      await tester.enterText(campoDialog, '0,08');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(reciclagem.totalKg, closeTo(0.08, 0.0001));
      expect(reciclagem.registros.first.pesoKg, 0.08);
    });

    testWidgets('cancelar diálogo de ajuste não altera o peso', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final reciclagem = ReciclagemModel(repo);
      await reciclagem.carregar();

      final guia = _criarGuiaFalso();
      final navegacao = NavegacaoModel();
      final conexao = ConexaoModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: guia),
            ChangeNotifierProvider.value(value: navegacao),
            ChangeNotifierProvider.value(value: conexao),
            ChangeNotifierProvider.value(value: reciclagem),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Garrafa');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar reciclagem'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajustar peso'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(reciclagem.totalKg, closeTo(0.03, 0.0001));
    });

    testWidgets('valores inválidos ou negativos no diálogo de ajuste são ignorados', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReciclagemRepository(prefs);
      final reciclagem = ReciclagemModel(repo);
      await reciclagem.carregar();

      final guia = _criarGuiaFalso();
      final navegacao = NavegacaoModel();
      final conexao = ConexaoModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: guia),
            ChangeNotifierProvider.value(value: navegacao),
            ChangeNotifierProvider.value(value: conexao),
            ChangeNotifierProvider.value(value: reciclagem),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Garrafa');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Registrar reciclagem'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajustar peso'));
      await tester.pumpAndSettle();

      final campoDialog = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
      await tester.enterText(campoDialog, '-0,05');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(reciclagem.totalKg, closeTo(0.03, 0.0001));
    });
    testWidgets('o aviso "Registrado!" some sozinho e não cobre as outras abas', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final reciclagem = ReciclagemModel(ReciclagemRepository(await SharedPreferences.getInstance()));
      await reciclagem.carregar();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: _criarGuiaFalso()),
            ChangeNotifierProvider.value(value: NavegacaoModel()),
            ChangeNotifierProvider.value(value: ConexaoModel()),
            ChangeNotifierProvider.value(value: reciclagem),
          ],
          child: MaterialApp(theme: criarTema(), home: const Scaffold(body: BuscarScreen())),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Garrafa');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar reciclagem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Registrado!'), findsOneWidget);

      // SnackBar padrão dura 4 s; com persist ele ficaria para sempre.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.textContaining('Registrado!'), findsNothing);
    });
  });
}
