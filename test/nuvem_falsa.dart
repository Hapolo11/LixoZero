import 'package:lixozero/models/lembrete.dart';
import 'package:lixozero/models/registro_reciclagem.dart';
import 'package:lixozero/services/nuvem_repositorio.dart';

/// Firestore de mentira: guarda tudo na memória, por usuário, e anota o que foi
/// pedido, para conferir nos testes.
class NuvemFalsa implements NuvemRepositorio {
  NuvemFalsa({this.disponivel = true});

  @override
  final bool disponivel;

  final registros = <String, Map<String, RegistroReciclagem>>{};
  final lembretes = <String, Map<int, Lembrete>>{};

  /// Quando preenchido, a próxima leitura ou gravação falha com este erro.
  Object? falha;
  int leituras = 0;
  final apagouTudoDe = <String>[];

  void _verificarFalha() {
    final erro = falha;
    if (erro != null) throw erro;
  }

  @override
  Future<List<RegistroReciclagem>> lerRegistros(String uid) async {
    leituras++;
    _verificarFalha();
    return [...?registros[uid]?.values];
  }

  @override
  Future<void> gravarRegistro(String uid, RegistroReciclagem registro) async {
    _verificarFalha();
    (registros[uid] ??= {})[registro.id] = registro;
  }

  @override
  Future<List<Lembrete>> lerLembretes(String uid) async {
    leituras++;
    _verificarFalha();
    return [...?lembretes[uid]?.values];
  }

  @override
  Future<void> gravarLembrete(String uid, Lembrete lembrete) async {
    _verificarFalha();
    (lembretes[uid] ??= {})[lembrete.id] = lembrete;
  }

  @override
  Future<void> apagarLembrete(String uid, int id) async {
    _verificarFalha();
    lembretes[uid]?.remove(id);
  }

  @override
  Future<void> apagarTudo(String uid) async {
    _verificarFalha();
    apagouTudoDe.add(uid);
    registros.remove(uid);
    lembretes.remove(uid);
  }
}
