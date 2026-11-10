import 'package:lixozero/models/lembrete.dart';
import 'package:lixozero/services/notificacoes.dart';

/// Guarda o que seria agendado no aparelho, para conferir nos testes.
class NotificacoesFalsas implements Notificacoes {
  final agendados = <int, Lembrete>{};
  int pedidosDePermissao = 0;
  bool permitir = true;
  int cancelamentos = 0;

  @override
  Future<void> iniciar() async {}

  @override
  Future<bool> pedirPermissao() async {
    pedidosDePermissao++;
    return permitir;
  }

  @override
  Future<void> agendar(Lembrete lembrete) async => agendados[lembrete.id] = lembrete;

  @override
  Future<void> cancelar(Lembrete lembrete) async {
    cancelamentos++;
    agendados.remove(lembrete.id);
  }
}
