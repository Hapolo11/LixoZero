import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/lembretes_repository.dart';
import 'package:lixozero/models/lembrete.dart';
import 'package:lixozero/services/notificacoes.dart';
import 'package:lixozero/state/lembretes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notificacoes_falsas.dart';

Lembrete _lembrete({int id = 1, int hora = 8, int minuto = 0, String titulo = 'Lixo orgânico', Set<int>? dias}) {
  return Lembrete(id: id, hora: hora, minuto: minuto, titulo: titulo, dias: dias ?? {DateTime.tuesday});
}

Future<(LembretesModel, NotificacoesFalsas, LembretesRepository)> _criarModel([Map<String, Object> inicial = const {}]) async {
  SharedPreferences.setMockInitialValues(inicial);
  final prefs = await SharedPreferences.getInstance();
  final repo = LembretesRepository(prefs);
  final notificacoes = NotificacoesFalsas();
  final model = LembretesModel(repo, notificacoes);
  await model.carregar();
  return (model, notificacoes, repo);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  group('Lembrete (modelo)', () {
    test('horário sempre com dois dígitos', () {
      expect(_lembrete(hora: 8, minuto: 5).horario, '08:05');
      expect(_lembrete(hora: 19, minuto: 30).horario, '19:30');
    });

    test('resumo igual ao protótipo: "Terça-feira às 08:00"', () {
      expect(_lembrete().resumo, 'Terça-feira às 08:00');
    });

    test('descrição dos dias para vários casos', () {
      expect(_lembrete(dias: {5, 1, 3}).descricaoDias, 'Seg, Qua e Sex');
      expect(_lembrete(dias: {2, 4}).descricaoDias, 'Ter e Qui');
      expect(_lembrete(dias: {1, 2, 3, 4, 5}).descricaoDias, 'Dias úteis');
      expect(_lembrete(dias: {1, 2, 3, 4, 5, 6, 7}).descricaoDias, 'Todos os dias');
      expect(_lembrete(dias: {6, 7}).descricaoDias, 'Sáb e Dom');
      expect(_lembrete(dias: {DateTime.sunday}).descricaoDias, 'Domingo');
    });

    test('JSON ida e volta mantém tudo igual', () {
      final original = _lembrete(id: 7, hora: 14, minuto: 15, titulo: 'Papel e plástico', dias: {4, 2});
      final json = original.toJson();
      expect(json['dias'], [2, 4]);
      expect(Lembrete.fromJson(json), original);
    });

    test('igualdade não depende da ordem dos dias', () {
      expect(_lembrete(dias: {1, 3}), _lembrete(dias: {3, 1}));
      expect(_lembrete(dias: {1, 3}).hashCode, _lembrete(dias: {3, 1}).hashCode);
      expect(_lembrete(dias: {1, 3}), isNot(_lembrete(dias: {1, 4})));
    });

    test('copyWith mantém o id e troca só o que foi passado', () {
      final editado = _lembrete(id: 3).copyWith(hora: 20, titulo: 'Vidro');
      expect(editado.id, 3);
      expect(editado.hora, 20);
      expect(editado.minuto, 0);
      expect(editado.titulo, 'Vidro');
      expect(editado.dias, {DateTime.tuesday});
    });

    test('a lista de dias não pode ser alterada por fora', () {
      expect(() => _lembrete().dias.add(1), throwsUnsupportedError);
    });
  });

  group('LembretesRepository', () {
    test('começa vazio', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await LembretesRepository(await SharedPreferences.getInstance()).carregar(), isEmpty);
    });

    test('salva e carrega de novo (continua depois de fechar o app, RNF14)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final lista = [_lembrete(id: 1), _lembrete(id: 2, hora: 14, dias: {4})];
      await LembretesRepository(prefs).salvar(lista);
      expect(await LembretesRepository(prefs).carregar(), lista);
    });

    test('dado corrompido não quebra: volta lista vazia', () async {
      SharedPreferences.setMockInitialValues({LembretesRepository.chave: '{isso não é json'});
      expect(await LembretesRepository(await SharedPreferences.getInstance()).carregar(), isEmpty);
    });
  });

  group('Agendamento das notificações', () {
    final fuso = tz.getLocation('America/Maceio');

    test('cada dia tem um id de notificação diferente', () {
      final l = _lembrete(id: 4, dias: {1, 2, 3, 4, 5, 6, 7});
      final ids = l.dias.map((d) => idNotificacao(l, d)).toSet();
      expect(ids.length, 7);
      expect(ids, containsAll([41, 47]));
    });

    test('próxima ocorrência mais tarde na mesma semana', () {
      // 10/11/2026 é uma terça-feira.
      final agora = tz.TZDateTime(fuso, 2026, 11, 10, 9, 0);
      final proxima = proximaOcorrencia(agora, DateTime.thursday, 14, 0);
      expect(proxima, tz.TZDateTime(fuso, 2026, 11, 12, 14, 0));
    });

    test('hoje, se o horário ainda não passou', () {
      final agora = tz.TZDateTime(fuso, 2026, 11, 10, 7, 0);
      expect(proximaOcorrencia(agora, DateTime.tuesday, 8, 0), tz.TZDateTime(fuso, 2026, 11, 10, 8, 0));
    });

    test('semana que vem, se o horário de hoje já passou', () {
      final agora = tz.TZDateTime(fuso, 2026, 11, 10, 8, 0);
      expect(proximaOcorrencia(agora, DateTime.tuesday, 8, 0), tz.TZDateTime(fuso, 2026, 11, 17, 8, 0));
    });

    test('vira o mês e o ano certinho', () {
      // 31/12/2026 é uma quinta-feira; a próxima segunda é 04/01/2027.
      final agora = tz.TZDateTime(fuso, 2026, 12, 31, 20, 0);
      expect(proximaOcorrencia(agora, DateTime.monday, 6, 30), tz.TZDateTime(fuso, 2027, 1, 4, 6, 30));
    });

    test('NotificacoesDesligadas não faz nada e não quebra', () async {
      const desligadas = NotificacoesDesligadas();
      await desligadas.iniciar();
      expect(await desligadas.pedirPermissao(), isFalse);
      await desligadas.agendar(_lembrete());
      await desligadas.cancelar(_lembrete());
    });
  });

  group('RF04 - LembretesModel (CRUD)', () {
    test('validação dos campos', () {
      String? v({int? hora = 8, int? minuto = 0, String titulo = 'Orgânico', Set<int> dias = const {1}}) =>
          LembretesModel.validar(hora: hora, minuto: minuto, titulo: titulo, dias: dias);

      expect(v(), isNull);
      expect(v(hora: 0, minuto: 0), isNull);
      expect(v(hora: 23, minuto: 59), isNull);
      expect(v(hora: null), contains('hora'));
      expect(v(hora: 24), contains('hora'));
      expect(v(hora: -1), contains('hora'));
      expect(v(minuto: null), contains('minutos'));
      expect(v(minuto: 60), contains('minutos'));
      expect(v(titulo: '   '), contains('título'));
      expect(v(dias: {}), contains('dia'));
    });

    test('criar salva, agenda e confere a permissão de notificar', () async {
      final (model, notificacoes, repo) = await _criarModel();

      final primeiro = await model.criar(hora: 8, minuto: 0, titulo: '  Lixo orgânico ', dias: {2});
      expect(primeiro.id, 1);
      expect(primeiro.titulo, 'Lixo orgânico');
      expect(model.lembretes, [primeiro]);
      expect(notificacoes.agendados.keys, [1]);
      expect(notificacoes.pedidosDePermissao, 1);

      final segundo = await model.criar(hora: 14, minuto: 0, titulo: 'Reciclável', dias: {4});
      expect(segundo.id, 2);
      expect(notificacoes.pedidosDePermissao, 2);
      expect(model.avisosPermitidos, isTrue);
      expect(await repo.carregar(), hasLength(2));
    });

    test('permissão negada: salva e agenda mesmo assim, e avisa a tela', () async {
      final (model, notificacoes, repo) = await _criarModel();
      notificacoes.permitir = false;
      await model.criar(hora: 8, minuto: 0, titulo: 'Orgânico', dias: {2});
      expect(model.avisosPermitidos, isFalse);
      expect(await repo.carregar(), hasLength(1));
      expect(notificacoes.agendados, hasLength(1));

      // Se depois ele liberar nas configurações, o próximo lembrete já percebe.
      notificacoes.permitir = true;
      await model.criar(hora: 9, minuto: 0, titulo: 'Vidro', dias: {3});
      expect(model.avisosPermitidos, isTrue);
    });

    test('criar com dados inválidos não salva nada', () async {
      final (model, notificacoes, _) = await _criarModel();
      expect(() => model.criar(hora: 8, minuto: 0, titulo: 'X', dias: {}), throwsArgumentError);
      expect(model.lembretes, isEmpty);
      expect(notificacoes.agendados, isEmpty);
    });

    test('lista ordenada pelo horário', () async {
      final (model, _, _) = await _criarModel();
      await model.criar(hora: 19, minuto: 0, titulo: 'Noite', dias: {1});
      await model.criar(hora: 6, minuto: 30, titulo: 'Manhã', dias: {1});
      await model.criar(hora: 6, minuto: 0, titulo: 'Bem cedo', dias: {1});
      expect(model.lembretes.map((l) => l.titulo), ['Bem cedo', 'Manhã', 'Noite']);
    });

    test('editar troca os dados, cancela o agendamento antigo e agenda o novo', () async {
      final (model, notificacoes, repo) = await _criarModel();
      final criado = await model.criar(hora: 8, minuto: 0, titulo: 'Orgânico', dias: {2});

      await model.editar(criado.copyWith(hora: 9, dias: {3, 5}));

      expect(model.lembretes.single.hora, 9);
      expect(model.lembretes.single.dias, {3, 5});
      expect(notificacoes.cancelamentos, 1);
      expect(notificacoes.agendados[criado.id]!.dias, {3, 5});
      expect((await repo.carregar()).single.hora, 9);
    });

    test('editar com dados inválidos lança erro e não muda nada', () async {
      final (model, _, _) = await _criarModel();
      final criado = await model.criar(hora: 8, minuto: 0, titulo: 'Orgânico', dias: {2});
      expect(() => model.editar(criado.copyWith(titulo: ' ')), throwsArgumentError);
      expect(model.lembretes.single.titulo, 'Orgânico');
    });

    test('editar ou excluir um id que não existe não faz nada', () async {
      final (model, notificacoes, _) = await _criarModel();
      await model.editar(_lembrete(id: 99));
      await model.excluir(99);
      expect(model.lembretes, isEmpty);
      expect(notificacoes.cancelamentos, 0);
    });

    test('excluir remove, salva e cancela a notificação', () async {
      final (model, notificacoes, repo) = await _criarModel();
      final a = await model.criar(hora: 8, minuto: 0, titulo: 'A', dias: {1});
      final b = await model.criar(hora: 9, minuto: 0, titulo: 'B', dias: {2});

      await model.excluir(a.id);

      expect(model.lembretes, [b]);
      expect(notificacoes.agendados.keys, [b.id]);
      expect(await repo.carregar(), [b]);
    });

    test('id novo continua depois do maior que já existe (sem repetir)', () async {
      final salvos = '[{"id":5,"hora":8,"minuto":0,"titulo":"Velho","dias":[1]}]';
      final (model, _, _) = await _criarModel({LembretesRepository.chave: salvos});
      expect(model.lembretes.single.id, 5);
      final novo = await model.criar(hora: 9, minuto: 0, titulo: 'Novo', dias: {2});
      expect(novo.id, 6);
    });

    test('avisa a tela quando a lista muda', () async {
      final (model, _, _) = await _criarModel();
      var avisos = 0;
      model.addListener(() => avisos++);
      final l = await model.criar(hora: 8, minuto: 0, titulo: 'A', dias: {1});
      await model.editar(l.copyWith(hora: 10));
      await model.excluir(l.id);
      expect(avisos, 3);
    });
  });
}
