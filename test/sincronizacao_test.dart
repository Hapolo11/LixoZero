
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/lembretes_repository.dart';
import 'package:lixozero/data/reciclagem_repository.dart';
import 'package:lixozero/models/lembrete.dart';
import 'package:lixozero/models/registro_reciclagem.dart';
import 'package:lixozero/services/auth_repositorio.dart';
import 'package:lixozero/services/nuvem_repositorio.dart';
import 'package:lixozero/state/auth_model.dart';
import 'package:lixozero/state/conexao_model.dart';
import 'package:lixozero/state/lembretes_model.dart';
import 'package:lixozero/state/reciclagem_model.dart';
import 'package:lixozero/state/sincronizacao_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_test.dart' show AuthFalso;
import 'notificacoes_falsas.dart';
import 'nuvem_falsa.dart';

const _uid = 'usuario-1';

RegistroReciclagem _registro(String id, {String item = 'Garrafa PET', double peso = 0.03, DateTime? data}) {
  return RegistroReciclagem(id: id, item: item, pesoKg: peso, data: data ?? DateTime(2026, 11, 3, 10, 30));
}

Lembrete _lembrete(int id, {String titulo = 'Lixo orgânico', int hora = 8}) {
  return Lembrete(id: id, hora: hora, minuto: 0, titulo: titulo, dias: {DateTime.tuesday});
}

Future<SharedPreferences> _prefs([Map<String, Object> inicial = const {}]) async {
  SharedPreferences.setMockInitialValues(inicial);
  return SharedPreferences.getInstance();
}

/// Deixa o código assíncrono que não é esperado (envios sem await) terminar.
Future<void> _esperar() => Future<void>.delayed(Duration.zero);

class _ConexaoFalsa extends ConexaoModel {
  bool _on = true;

  @override
  bool get online => _on;

  void definir(bool valor) {
    _on = valor;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('conversão para o Firestore', () {
    test('registro vai e volta sem perder nada', () {
      final original = _registro('abc', peso: 0.055);
      final documento = documentoDeRegistro(original);

      expect(documento.keys, unorderedEquals(['item', 'pesoKg', 'data']));
      expect(documento['data'], isA<Timestamp>());
      expect(registroDeDocumento('abc', documento), original);
    });

    test('lembrete vai e volta sem perder nada', () {
      final original = Lembrete(id: 7, hora: 19, minuto: 30, titulo: 'Papel', dias: {1, 3, 5});
      final documento = documentoDeLembrete(original);

      expect(documento.keys, unorderedEquals(['hora', 'minuto', 'titulo', 'dias']));
      expect(lembreteDeDocumento('7', documento), original);
    });

    test('documentos incompletos ou ruins são ignorados em vez de travar o app', () {
      expect(registroDeDocumento('x', {'item': 'PET'}), isNull);
      expect(registroDeDocumento('x', {'item': 'PET', 'pesoKg': -1, 'data': Timestamp.now()}), isNull);
      expect(lembreteDeDocumento('nao-e-numero', {'hora': 8, 'minuto': 0, 'titulo': 'A', 'dias': [1]}), isNull);
      expect(lembreteDeDocumento('1', {'hora': 8}), isNull);
    });
  });

  group('registros de reciclagem na nuvem', () {
    test('sem conta, nada vai para a nuvem', () async {
      final nuvem = NuvemFalsa();
      final model = ReciclagemModel(ReciclagemRepository(await _prefs()), nuvem);

      await model.registrar('Garrafa PET', 0.03);
      await _esperar();

      expect(nuvem.registros, isEmpty);
      expect(model.registros, hasLength(1));
    });

    test('com conta, registrar e ajustar o peso também grava na nuvem', () async {
      final nuvem = NuvemFalsa();
      final model = ReciclagemModel(ReciclagemRepository(await _prefs()), nuvem)..definirUsuario(_uid);

      final registro = await model.registrar('Garrafa PET', 0.03);
      await _esperar();
      expect(nuvem.registros[_uid]![registro.id]!.pesoKg, 0.03);

      await model.ajustarPeso(registro.id, 0.05);
      await _esperar();
      expect(nuvem.registros[_uid]![registro.id]!.pesoKg, 0.05);
    });

    test('falha ao enviar não derruba o registro local', () async {
      final nuvem = NuvemFalsa()..falha = StateError('sem internet');
      final model = ReciclagemModel(ReciclagemRepository(await _prefs()), nuvem)..definirUsuario(_uid);

      await model.registrar('Garrafa PET', 0.03);
      await _esperar();

      expect(model.registros, hasLength(1));
      expect(model.totalKg, closeTo(0.03, 1e-9));
    });

    test('sincronizar junta o que está só no aparelho com o que está só na conta', () async {
      final nuvem = NuvemFalsa();
      nuvem.registros[_uid] = {'nuvem': _registro('nuvem', item: 'Lata', peso: 0.02, data: DateTime(2026, 11, 1))};
      final repo = ReciclagemRepository(await _prefs());
      await repo.salvar([_registro('local', peso: 0.03)]);
      final model = ReciclagemModel(repo, nuvem)..definirUsuario(_uid);
      await model.carregar();

      await model.sincronizar();
      await _esperar();

      expect(model.registros.map((r) => r.id), ['nuvem', 'local'], reason: 'ordenado pela data');
      expect(model.totalKg, closeTo(0.05, 1e-9));
      expect(nuvem.registros[_uid]!.keys, unorderedEquals(['nuvem', 'local']));
      expect((await ReciclagemRepository(await SharedPreferences.getInstance()).carregar()).length, 2,
          reason: 'o que veio da conta também fica salvo no aparelho');
    });

    test('registro igual dos dois lados não duplica', () async {
      final nuvem = NuvemFalsa();
      nuvem.registros[_uid] = {'a': _registro('a')};
      final repo = ReciclagemRepository(await _prefs());
      await repo.salvar([_registro('a')]);
      final model = ReciclagemModel(repo, nuvem)..definirUsuario(_uid);
      await model.carregar();

      await model.sincronizar();

      expect(model.registros, hasLength(1));
      expect(nuvem.registros[_uid], hasLength(1));
    });

    test('se o mesmo registro tem pesos diferentes, vale o do aparelho', () async {
      final nuvem = NuvemFalsa();
      nuvem.registros[_uid] = {'a': _registro('a', peso: 0.03)};
      final repo = ReciclagemRepository(await _prefs());
      await repo.salvar([_registro('a', peso: 0.08)]);
      final model = ReciclagemModel(repo, nuvem)..definirUsuario(_uid);
      await model.carregar();

      await model.sincronizar();
      await _esperar();

      expect(model.registros.single.pesoKg, 0.08);
      expect(nuvem.registros[_uid]!['a']!.pesoKg, 0.08);
    });

    test('sem conta ou sem Firebase, sincronizar não faz nada', () async {
      final nuvem = NuvemFalsa();
      final semConta = ReciclagemModel(ReciclagemRepository(await _prefs()), nuvem);
      await semConta.sincronizar();
      expect(nuvem.leituras, 0);

      final semFirebase = ReciclagemModel(ReciclagemRepository(await _prefs()), NuvemFalsa(disponivel: false))
        ..definirUsuario(_uid);
      await semFirebase.sincronizar();
    });

    test('erro na leitura chega a quem chamou, para a tela avisar', () async {
      final nuvem = NuvemFalsa()..falha = StateError('permission-denied');
      final model = ReciclagemModel(ReciclagemRepository(await _prefs()), nuvem)..definirUsuario(_uid);

      await expectLater(model.sincronizar(), throwsStateError);
    });
  });

  group('lembretes na nuvem', () {
    Future<(LembretesModel, NotificacoesFalsas)> criar(NuvemFalsa nuvem, {String? uid = _uid}) async {
      final notificacoes = NotificacoesFalsas();
      final model = LembretesModel(LembretesRepository(await _prefs()), notificacoes, nuvem);
      if (uid != null) model.definirUsuario(uid);
      await model.carregar();
      return (model, notificacoes);
    }

    test('criar, editar e excluir acompanham a nuvem', () async {
      final nuvem = NuvemFalsa();
      final (model, _) = await criar(nuvem);

      final lembrete = await model.criar(hora: 8, minuto: 0, titulo: 'Lixo orgânico', dias: {DateTime.tuesday});
      await _esperar();
      expect(nuvem.lembretes[_uid]![lembrete.id]!.titulo, 'Lixo orgânico');

      await model.editar(lembrete.copyWith(titulo: 'Papel', hora: 9));
      await _esperar();
      expect(nuvem.lembretes[_uid]![lembrete.id]!.titulo, 'Papel');
      expect(nuvem.lembretes[_uid]![lembrete.id]!.hora, 9);

      await model.excluir(lembrete.id);
      await _esperar();
      expect(nuvem.lembretes[_uid], isEmpty);
    });

    test('sem conta, os lembretes ficam só no aparelho', () async {
      final nuvem = NuvemFalsa();
      final (model, _) = await criar(nuvem, uid: null);

      await model.criar(hora: 8, minuto: 0, titulo: 'Lixo orgânico', dias: {DateTime.tuesday});
      await _esperar();

      expect(nuvem.lembretes, isEmpty);
    });

    test('sincronizar traz os lembretes da conta e agenda a notificação neste aparelho', () async {
      final nuvem = NuvemFalsa();
      nuvem.lembretes[_uid] = {3: _lembrete(3, titulo: 'Vidro', hora: 7)};
      final (model, notificacoes) = await criar(nuvem);
      await model.criar(hora: 8, minuto: 0, titulo: 'Papel', dias: {DateTime.friday});
      await _esperar();

      await model.sincronizar();
      await _esperar();

      expect(model.lembretes.map((l) => l.titulo), ['Vidro', 'Papel'], reason: 'ordenados pelo horário');
      expect(notificacoes.agendados.keys, contains(3));
      expect(nuvem.lembretes[_uid]!.keys, unorderedEquals([1, 3]));
    });

    test('falha ao enviar não derruba o lembrete local', () async {
      final nuvem = NuvemFalsa()..falha = StateError('sem internet');
      final (model, notificacoes) = await criar(nuvem);

      await model.criar(hora: 8, minuto: 0, titulo: 'Lixo orgânico', dias: {DateTime.tuesday});
      await _esperar();

      expect(model.lembretes, hasLength(1));
      expect(notificacoes.agendados, hasLength(1));
    });
  });

  group('SincronizacaoModel', () {
    Future<
        ({
          SincronizacaoModel sync,
          AuthFalso authRepo,
          AuthModel auth,
          _ConexaoFalsa conexao,
          ReciclagemModel reciclagem,
          LembretesModel lembretes,
          NuvemFalsa nuvem
        })> montar({bool online = true}) async {
      final prefs = await _prefs();
      final nuvem = NuvemFalsa();
      final authRepo = AuthFalso();
      final auth = AuthModel(authRepo, prefs);
      final conexao = _ConexaoFalsa().._on = online;
      final reciclagem = ReciclagemModel(ReciclagemRepository(prefs), nuvem);
      final lembretes = LembretesModel(LembretesRepository(prefs), NotificacoesFalsas(), nuvem);
      final sync = SincronizacaoModel(auth: auth, conexao: conexao, reciclagem: reciclagem, lembretes: lembretes);
      return (sync: sync, authRepo: authRepo, auth: auth, conexao: conexao, reciclagem: reciclagem, lembretes: lembretes, nuvem: nuvem);
    }

    test('visitante: estado "sem conta" e nada na nuvem', () async {
      final m = await montar();
      expect(m.sync.estado, EstadoSincronizacao.semConta);

      await m.reciclagem.registrar('Garrafa PET', 0.03);
      await _esperar();
      expect(m.nuvem.registros, isEmpty);
    });

    test('ao entrar na conta, sincroniza e passa a enviar os novos registros', () async {
      final m = await montar();
      await m.reciclagem.registrar('Lata', 0.02); // feito antes de entrar, como visitante
      m.nuvem.registros['1'] = {'nuvem': _registro('nuvem')};

      await m.auth.entrar('ana@email.com', '123456'); // o AuthFalso usa uid "1"
      await _esperar();

      expect(m.sync.estado, EstadoSincronizacao.sincronizado);
      expect(m.sync.sincronizadoEm, isNotNull);
      expect(m.reciclagem.registros, hasLength(2), reason: 'veio o da conta e o do aparelho foi para a conta');
      expect(m.nuvem.registros['1'], hasLength(2));

      await m.reciclagem.registrar('Garrafa PET', 0.03);
      await _esperar();
      expect(m.nuvem.registros['1'], hasLength(3));
    });

    test('ao sair da conta, para de enviar', () async {
      final m = await montar();
      await m.auth.entrar('ana@email.com', '123456');
      await _esperar();

      await m.auth.sair();
      await _esperar();
      expect(m.sync.estado, EstadoSincronizacao.semConta);

      await m.reciclagem.registrar('Garrafa PET', 0.03);
      await _esperar();
      expect(m.nuvem.registros['1'] ?? {}, isEmpty);
    });

    test('sem internet espera; quando a conexão volta, sincroniza', () async {
      final m = await montar(online: false);
      m.nuvem.registros['1'] = {'nuvem': _registro('nuvem')};

      await m.auth.entrar('ana@email.com', '123456');
      await _esperar();
      expect(m.sync.estado, EstadoSincronizacao.aguardandoInternet);
      expect(m.reciclagem.registros, isEmpty);

      m.conexao.definir(true);
      await _esperar();
      expect(m.sync.estado, EstadoSincronizacao.sincronizado);
      expect(m.reciclagem.registros, hasLength(1));
    });

    test('falha vira estado de erro e "tentar de novo" resolve', () async {
      final m = await montar();
      m.nuvem.falha = StateError('permission-denied');

      await m.auth.entrar('ana@email.com', '123456');
      await _esperar();
      expect(m.sync.estado, EstadoSincronizacao.erro);

      m.nuvem.falha = null;
      await m.sync.sincronizarAgora();
      expect(m.sync.estado, EstadoSincronizacao.sincronizado);
    });
  });

  group('excluir a conta', () {
    test('apaga os dados da nuvem antes de apagar a conta', () async {
      final prefs = await _prefs();
      final authRepo = AuthFalso();
      final nuvem = NuvemFalsa();
      nuvem.registros['1'] = {'a': _registro('a')};
      final auth = AuthModel(authRepo, prefs, antesDeExcluir: nuvem.apagarTudo);
      await auth.entrar('ana@email.com', '123456');

      await auth.excluirConta();

      expect(nuvem.apagouTudoDe, ['1']);
      expect(nuvem.registros, isEmpty);
      expect(authRepo.chamadas, contains('excluir'));
      expect(auth.sessao, Sessao.precisaEscolher);
    });

    test('se os dados da nuvem não forem apagados, a conta também não é', () async {
      final prefs = await _prefs();
      final authRepo = AuthFalso();
      final nuvem = NuvemFalsa()..falha = StateError('sem internet');
      final auth = AuthModel(authRepo, prefs, antesDeExcluir: nuvem.apagarTudo);
      await auth.entrar('ana@email.com', '123456');

      await expectLater(auth.excluirConta(), throwsA(isA<AuthFalha>()));

      expect(authRepo.chamadas, isNot(contains('excluir')));
      expect(auth.sessao, Sessao.logado);
    });
  });
}
