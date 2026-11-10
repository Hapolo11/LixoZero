import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/app.dart';
import 'package:lixozero/data/guia_repository.dart';
import 'package:lixozero/data/lembretes_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/models/categoria.dart';
import 'package:lixozero/models/item_guia.dart';
import 'package:lixozero/models/registro_reciclagem.dart';
import 'package:lixozero/screens/impacto_screen.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/dicas_model.dart';
import 'package:lixozero/state/lembretes_model.dart';
import 'package:lixozero/state/navegacao_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dicas_falsas.dart';
import 'notificacoes_falsas.dart';

String _registrosJson(List<RegistroReciclagem> registros) => jsonEncode(registros.map((r) => r.toJson()).toList());

class _Ambiente {
  _Ambiente(this.reciclagem, this.lembretes, this.notificacoes);

  final ReciclagemModel reciclagem;
  final LembretesModel lembretes;
  final NotificacoesFalsas notificacoes;
}

Future<_Ambiente> _montar(
  WidgetTester tester, {
  List<RegistroReciclagem> registros = const [],
  String? lembretesJson,
}) async {
  SharedPreferences.setMockInitialValues({
    if (registros.isNotEmpty) ReciclagemRepository.chave: _registrosJson(registros),
    LembretesRepository.chave: ?lembretesJson,
  });
  final prefs = await SharedPreferences.getInstance();
  final reciclagem = ReciclagemModel(ReciclagemRepository(prefs));
  final notificacoes = NotificacoesFalsas();
  final lembretes = LembretesModel(LembretesRepository(prefs), notificacoes);
  await tester.runAsync(() async {
    await reciclagem.carregar();
    await lembretes.carregar();
  });

  // Tela alta para caber o formulário inteiro sem rolar.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConexaoModel()),
        ChangeNotifierProvider.value(value: reciclagem),
        ChangeNotifierProvider.value(value: lembretes),
      ],
      child: MaterialApp(theme: criarTema(), home: const Scaffold(body: ImpactoScreen())),
    ),
  );
  await tester.pump();
  return _Ambiente(reciclagem, lembretes, notificacoes);
}

RegistroReciclagem _registro(String id, double kg, DateTime data) =>
    RegistroReciclagem(id: id, item: 'Garrafa PET', pesoKg: kg, data: data);

/// Preenche o formulário de lembrete aberto.
Future<void> _preencher(WidgetTester tester, {String? horas, String? minutos, String? titulo, List<int> dias = const []}) async {
  if (horas != null) await tester.enterText(find.byKey(const Key('campo_horas')), horas);
  if (minutos != null) await tester.enterText(find.byKey(const Key('campo_minutos')), minutos);
  if (titulo != null) await tester.enterText(find.byKey(const Key('campo_titulo')), titulo);
  for (final dia in dias) {
    await tester.tap(find.byKey(Key('dia_$dia')));
  }
  await tester.pump();
}

void main() {
  group('formatarKg', () {
    test('vírgula e até duas casas', () {
      expect(formatarKg(0), '0');
      expect(formatarKg(0.03), '0,03');
      expect(formatarKg(12.5), '12,5');
      expect(formatarKg(1234.567), '1.234,57');
    });
  });

  group('RF03 - ReciclagemModel.totalDoMes', () {
    test('soma só o mês pedido', () async {
      final agora = DateTime(2026, 11, 10);
      SharedPreferences.setMockInitialValues({
        ReciclagemRepository.chave: _registrosJson([
          _registro('a', 0.5, DateTime(2026, 11, 1)),
          _registro('b', 0.25, DateTime(2026, 11, 30, 23, 59)),
          _registro('c', 2.0, DateTime(2026, 10, 31, 23, 59)),
          _registro('d', 4.0, DateTime(2025, 11, 10)), // mesmo mês, outro ano
        ]),
      });
      final model = ReciclagemModel(ReciclagemRepository(await SharedPreferences.getInstance()));
      await model.carregar();

      expect(model.totalDoMes(agora), closeTo(0.75, 1e-9));
      expect(model.totalDoMes(DateTime(2026, 10, 5)), closeTo(2.0, 1e-9));
      expect(model.totalKg, closeTo(6.75, 1e-9));
    });

    test('sem registros dá zero', () async {
      SharedPreferences.setMockInitialValues({});
      final model = ReciclagemModel(ReciclagemRepository(await SharedPreferences.getInstance()));
      await model.carregar();
      expect(model.totalDoMes(), 0);
    });
  });

  group('RF03 - Contador na tela Impacto', () {
    testWidgets('sem registros: 0 kg e explica como começar', (tester) async {
      await _montar(tester);
      expect(find.text('Seu impacto'), findsOneWidget);
      expect(find.text('0 kg'), findsOneWidget);
      expect(find.textContaining('Registrar reciclagem'), findsOneWidget);
      expect(find.byKey(const Key('contador_total')), findsNothing);
    });

    testWidgets('mostra o mês em destaque e o total desde o começo', (tester) async {
      final agora = DateTime.now();
      await _montar(tester, registros: [
        _registro('a', 10, agora),
        _registro('b', 2.5, agora),
        _registro('c', 3, DateTime(agora.year - 1, agora.month, 1)),
      ]);
      expect(find.text('12,5 kg'), findsOneWidget);
      expect(find.text('reciclados este mês'), findsOneWidget);
      expect(find.text('"Cada grama conta!"'), findsOneWidget);
      expect(find.text('Desde o começo: 15,5 kg em 3 registros'), findsOneWidget);
    });

    testWidgets('singular com um registro só', (tester) async {
      await _montar(tester, registros: [_registro('a', 0.03, DateTime.now())]);
      expect(find.text('0,03 kg'), findsOneWidget);
      expect(find.text('Desde o começo: 0,03 kg em 1 registro'), findsOneWidget);
    });

    testWidgets('atualiza na hora quando um novo registro é feito', (tester) async {
      final ambiente = await _montar(tester);
      await tester.runAsync(() => ambiente.reciclagem.registrar('Lata', 0.015));
      await tester.pump();
      expect(find.text('0,02 kg'), findsOneWidget); // 0,015 arredonda para 0,02
    });
  });

  group('RF04 - Lembretes na tela Impacto', () {
    testWidgets('sem lembretes: mensagem e botão "Novo lembrete"', (tester) async {
      await _montar(tester);
      expect(find.text('Lembretes de coleta'), findsOneWidget);
      expect(find.textContaining('Nenhum lembrete ainda'), findsOneWidget);
      expect(find.text('Novo lembrete'), findsOneWidget);
    });

    testWidgets('mostra os lembretes salvos como no protótipo', (tester) async {
      await _montar(
        tester,
        lembretesJson: '[{"id":1,"hora":8,"minuto":0,"titulo":"Lixo Orgânico","dias":[2]},'
            '{"id":2,"hora":14,"minuto":0,"titulo":"Lixo Reciclável (Papel/Plástico)","dias":[4]}]',
      );
      expect(find.text('Terça-feira às 08:00'), findsOneWidget);
      expect(find.text('Lixo Orgânico'), findsOneWidget);
      expect(find.text('Quinta-feira às 14:00'), findsOneWidget);
      expect(find.byTooltip('Editar lembrete'), findsNWidgets(2));
      expect(find.byTooltip('Apagar lembrete'), findsNWidgets(2));
      expect(find.textContaining('Nenhum lembrete ainda'), findsNothing);
    });

    testWidgets('criar um lembrete pelo formulário', (tester) async {
      final ambiente = await _montar(tester);

      await tester.tap(find.text('Novo lembrete'));
      await tester.pumpAndSettle();
      expect(find.text('Adicionar Lembrete'), findsOneWidget);
      expect(find.text('Segunda-feira'), findsOneWidget);
      expect(find.text('Domingo'), findsOneWidget);

      await _preencher(tester, horas: '8', minutos: '0', titulo: 'Lixo orgânico', dias: [DateTime.tuesday]);
      await tester.tap(find.text('Criar'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Lembrete'), findsNothing);
      expect(find.text('Terça-feira às 08:00'), findsOneWidget);
      expect(find.text('Lixo orgânico'), findsOneWidget);
      expect(find.text('Lembrete criado!'), findsOneWidget);
      expect(ambiente.lembretes.lembretes, hasLength(1));
      expect(ambiente.notificacoes.agendados, hasLength(1));
    });

    testWidgets('com notificações negadas, avisa que o lembrete não vai tocar', (tester) async {
      final ambiente = await _montar(tester);
      ambiente.notificacoes.permitir = false;

      await tester.tap(find.text('Novo lembrete'));
      await tester.pumpAndSettle();
      await _preencher(tester, horas: '8', minutos: '0', titulo: 'Vidro', dias: [DateTime.friday]);
      await tester.tap(find.text('Criar'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('Sexta-feira às 08:00'), findsOneWidget);
      expect(find.textContaining('notificações estão desligadas'), findsOneWidget);
    });

    testWidgets('formulário mostra erro e não fecha com dados faltando', (tester) async {
      final ambiente = await _montar(tester);
      await tester.tap(find.text('Novo lembrete'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(find.text('A hora vai de 0 a 23.'), findsOneWidget);

      await _preencher(tester, horas: '25', minutos: '00');
      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(find.text('A hora vai de 0 a 23.'), findsOneWidget);

      await _preencher(tester, horas: '07', minutos: '75');
      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(find.text('Os minutos vão de 0 a 59.'), findsOneWidget);

      await _preencher(tester, minutos: '30');
      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(find.textContaining('Dê um título'), findsOneWidget);

      await _preencher(tester, titulo: 'Vidro');
      await tester.tap(find.text('Criar'));
      await tester.pump();
      expect(find.text('Escolha pelo menos um dia da semana.'), findsOneWidget);

      expect(find.text('Adicionar Lembrete'), findsOneWidget);
      expect(ambiente.lembretes.lembretes, isEmpty);
    });

    testWidgets('campos de hora aceitam só números, até 2 dígitos', (tester) async {
      await _montar(tester);
      await tester.tap(find.text('Novo lembrete'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('campo_horas')), '1a2b3');
      await tester.pump();
      final campo = tester.widget<TextField>(find.byKey(const Key('campo_horas')));
      expect(campo.controller!.text, '12');
    });

    testWidgets('cancelar o formulário não cria nada', (tester) async {
      final ambiente = await _montar(tester);
      await tester.tap(find.text('Novo lembrete'));
      await tester.pumpAndSettle();
      await _preencher(tester, horas: '8', minutos: '0', titulo: 'X', dias: [1]);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Adicionar Lembrete'), findsNothing);
      expect(ambiente.lembretes.lembretes, isEmpty);
    });

    testWidgets('editar abre preenchido e salva as mudanças', (tester) async {
      final ambiente = await _montar(
        tester,
        lembretesJson: '[{"id":1,"hora":8,"minuto":0,"titulo":"Lixo Orgânico","dias":[2]}]',
      );

      await tester.tap(find.byTooltip('Editar lembrete'));
      await tester.pumpAndSettle();
      expect(find.text('Editar Lembrete'), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('campo_horas'))).controller!.text, '08');
      expect(tester.widget<TextField>(find.byKey(const Key('campo_minutos'))).controller!.text, '00');
      expect(tester.widget<TextField>(find.byKey(const Key('campo_titulo'))).controller!.text, 'Lixo Orgânico');
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('dia_2'))).value, isTrue);
      expect(tester.widget<CheckboxListTile>(find.byKey(const Key('dia_1'))).value, isFalse);

      // Passa de terça para terça e quinta, às 09:30.
      await _preencher(tester, horas: '9', minutos: '30', dias: [DateTime.thursday]);
      await tester.tap(find.text('Salvar'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('Ter e Qui às 09:30'), findsOneWidget);
      expect(ambiente.lembretes.lembretes.single.dias, {2, 4});
      expect(ambiente.notificacoes.cancelamentos, 1);
    });

    testWidgets('apagar pede confirmação; X não apaga', (tester) async {
      final ambiente = await _montar(
        tester,
        lembretesJson: '[{"id":1,"hora":8,"minuto":0,"titulo":"Lixo Orgânico","dias":[2]}]',
      );

      await tester.tap(find.byTooltip('Apagar lembrete'));
      await tester.pumpAndSettle();
      expect(find.text('Certeza que quer apagar?'), findsOneWidget);

      await tester.tap(find.byTooltip('Não apagar'));
      await tester.pumpAndSettle();
      expect(find.text('Terça-feira às 08:00'), findsOneWidget);
      expect(ambiente.lembretes.lembretes, hasLength(1));
    });

    testWidgets('apagar com ✓ remove o lembrete', (tester) async {
      final ambiente = await _montar(
        tester,
        lembretesJson: '[{"id":1,"hora":8,"minuto":0,"titulo":"Lixo Orgânico","dias":[2]}]',
      );

      await tester.tap(find.byTooltip('Apagar lembrete'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Apagar'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('Terça-feira às 08:00'), findsNothing);
      expect(find.textContaining('Nenhum lembrete ainda'), findsOneWidget);
      expect(ambiente.lembretes.lembretes, isEmpty);
      expect(ambiente.notificacoes.cancelamentos, 1);
    });
  });

  group('Integração com o app', () {
    testWidgets('a aba Impacto abre a tela nova (não mais "Em construção")', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final reciclagem = ReciclagemModel(ReciclagemRepository(prefs));
      final lembretes = LembretesModel(LembretesRepository(prefs), NotificacoesFalsas());
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
          sinonimos: ['pet'],
          categoriaId: 'plastico',
          destino: 'coleta_seletiva',
          pesoKg: 0.03,
          instrucao: 'Enxágue e descarte no reciclável.',
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: GuiaRepository(categorias, itens, {'coleta_seletiva': 'Coleta seletiva'})),
            ChangeNotifierProvider(create: (_) => ConexaoModel()),
            ChangeNotifierProvider.value(value: reciclagem),
            ChangeNotifierProvider.value(value: lembretes),
            ChangeNotifierProvider(create: (_) => NavegacaoModel()),
            ChangeNotifierProvider(create: (_) => DicasModel(dicasDeTeste)),
          ],
          child: MaterialApp(theme: criarTema(), home: const TelaPrincipal()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Impacto'));
      await tester.pumpAndSettle();

      expect(find.byType(ImpactoScreen), findsOneWidget);
      expect(find.text('Seu impacto'), findsOneWidget);
      expect(find.textContaining('Em construção'), findsNothing);
    });
  });
}
