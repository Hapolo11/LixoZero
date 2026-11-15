import 'package:flutter/foundation.dart';

import '../data/lembretes_repository.dart';
import '../models/lembrete.dart';
import '../services/notificacoes.dart';

/// CRUD dos lembretes de coleta (RF04). Salva no aparelho e mantém as
/// notificações agendadas em dia com a lista.
class LembretesModel extends ChangeNotifier {
  LembretesModel(this._repo, this._notificacoes);

  final LembretesRepository _repo;
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
    await _notificacoes.cancelar(antigo);
    await _notificacoes.agendar(novo);
  }

  Future<void> excluir(int id) async {
    final index = _lembretes.indexWhere((l) => l.id == id);
    if (index == -1) return;
    final removido = _lembretes.removeAt(index);
    notifyListeners();
    await _repo.salvar(_lembretes);
    await _notificacoes.cancelar(removido);
  }
}
