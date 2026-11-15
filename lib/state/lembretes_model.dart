import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/lembretes_repository.dart';
import '../models/lembrete.dart';
import '../services/notificacoes.dart';
import '../services/nuvem_repositorio.dart';

/// CRUD dos lembretes de coleta (RF04). Salva no aparelho e mantém as
/// notificações agendadas em dia com a lista. Quem tem conta também envia os
/// lembretes para o Firestore.
class LembretesModel extends ChangeNotifier {
  LembretesModel(this._repo, this._notificacoes, [this._nuvem]);

  final LembretesRepository _repo;
  final NuvemRepositorio? _nuvem;
  String? _uid;
  final Notificacoes _notificacoes;
  List<Lembrete> _lembretes = [];
  bool _avisosPermitidos = true;

  /// Ordenados pelo horário, para a lista ficar previsível.
  List<Lembrete> get lembretes {
    final copia = [..._lembretes];
    copia.sort((a, b) {
      final porHora = (a.hora * 60 + a.minuto).compareTo(b.hora * 60 + b.minuto);
      return porHora != 0 ? porHora : a.id.compareTo(b.id);
    });
    return List.unmodifiable(copia);
  }

  /// Falso quando o usuário negou as notificações: o lembrete fica salvo,
  /// mas não toca. A tela usa isso para avisar.
  bool get avisosPermitidos => _avisosPermitidos;

  Future<void> carregar() async {
    _lembretes = await _repo.carregar();
    notifyListeners();
  }

  /// Chamado quando o usuário entra ou sai da conta. Com [uid] nulo, nada é
  /// enviado para a nuvem.
  void definirUsuario(String? uid) => _uid = uid;

  /// Valida os campos do formulário. Devolve a mensagem de erro ou null.
  static String? validar({required int? hora, required int? minuto, required String titulo, required Set<int> dias}) {
    if (hora == null || hora < 0 || hora > 23) return 'A hora vai de 0 a 23.';
    if (minuto == null || minuto < 0 || minuto > 59) return 'Os minutos vão de 0 a 59.';
    if (titulo.trim().isEmpty) return 'Dê um título ao lembrete, como "Lixo orgânico".';
    if (dias.isEmpty) return 'Escolha pelo menos um dia da semana.';
    return null;
  }

  Future<Lembrete> criar({required int hora, required int minuto, required String titulo, required Set<int> dias}) async {
    final erro = validar(hora: hora, minuto: minuto, titulo: titulo, dias: dias);
    if (erro != null) throw ArgumentError(erro);

    // Ids pequenos e crescentes: cabem no id de notificação (id * 10 + dia).
    final proximoId = _lembretes.fold<int>(0, (maior, l) => l.id > maior ? l.id : maior) + 1;
    final lembrete = Lembrete(id: proximoId, hora: hora, minuto: minuto, titulo: titulo.trim(), dias: dias);
    _lembretes.add(lembrete);
    notifyListeners();
    await _repo.salvar(_lembretes);
    _enviar(lembrete);

    // Só pede permissão quando o usuário mostra que quer ser avisado. Se já
    // foi aceita, o sistema responde na hora, sem mostrar nada.
    _avisosPermitidos = await _notificacoes.pedirPermissao();
    await _notificacoes.agendar(lembrete);
    return lembrete;
  }

  Future<void> editar(Lembrete atualizado) async {
    final erro = validar(
      hora: atualizado.hora,
      minuto: atualizado.minuto,
      titulo: atualizado.titulo,
      dias: atualizado.dias,
    );
    if (erro != null) throw ArgumentError(erro);

    final index = _lembretes.indexWhere((l) => l.id == atualizado.id);
    if (index == -1) return;
    final antigo = _lembretes[index];
    final novo = atualizado.copyWith(titulo: atualizado.titulo.trim());
    _lembretes[index] = novo;
    notifyListeners();
    await _repo.salvar(_lembretes);
    _enviar(novo);
    await _notificacoes.cancelar(antigo);
    await _notificacoes.agendar(novo);
  }

  Future<void> excluir(int id) async {
    final index = _lembretes.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final removido = _lembretes.removeAt(index);
    notifyListeners();
    await _repo.salvar(_lembretes);
    _apagarNaNuvem(removido.id);
    await _notificacoes.cancelar(removido);
  }

  /// Junta os lembretes do aparelho com os da conta: o que só existe de um
  /// lado vai para o outro (e os novos lembretes da conta passam a tocar neste
  /// aparelho). Se o mesmo id existir dos dois lados com conteúdo diferente,
  /// vale o do aparelho. Chamado ao entrar na conta e quando a internet volta.
  Future<void> sincronizar() async {
    final uid = _uid;
    final nuvem = _nuvem;
    if (uid == null || nuvem == null || !nuvem.disponivel) return;

    final remotos = {for (final l in await nuvem.lerLembretes(uid)) l.id: l};
    final locais = {for (final l in _lembretes) l.id: l};

    final novos = <Lembrete>[];
    for (final remoto in remotos.values) {
      if (!locais.containsKey(remoto.id)) novos.add(remoto);
    }
    for (final local in locais.values) {
      if (remotos[local.id] != local) _enviar(local);
    }

    if (novos.isEmpty) return;
    _lembretes.addAll(novos);
    notifyListeners();
    await _repo.salvar(_lembretes);
    for (final lembrete in novos) {
      try {
        await _notificacoes.agendar(lembrete);
      } catch (e) {
        debugPrint('Lembrete ${lembrete.id} não agendado: $e');
      }
    }
  }

  /// Envia sem esperar a resposta do servidor: sem internet, o Firestore
  /// guarda a gravação e envia quando a conexão volta.
  void _enviar(Lembrete lembrete) {
    final uid = _uid;
    final nuvem = _nuvem;
    if (uid == null || nuvem == null || !nuvem.disponivel) return;
    unawaited(nuvem.gravarLembrete(uid, lembrete).catchError((Object e) {
      debugPrint('Lembrete ${lembrete.id} não enviado: $e');
    }));
  }

  void _apagarNaNuvem(int id) {
    final uid = _uid;
    final nuvem = _nuvem;
    if (uid == null || nuvem == null || !nuvem.disponivel) return;
    unawaited(nuvem.apagarLembrete(uid, id).catchError((Object e) {
      debugPrint('Lembrete $id não apagado na nuvem: $e');
    }));
  }
}
