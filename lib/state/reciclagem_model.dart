import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/reciclagem_repository.dart';
import '../models/registro_reciclagem.dart';
import '../services/nuvem_repositorio.dart';

/// Guarda os registros de reciclagem (RF09).
///
/// Os registros sempre ficam no aparelho, então tudo funciona sem internet e
/// sem conta. Quem tem conta também envia os registros para o Firestore.
class ReciclagemModel extends ChangeNotifier {
  ReciclagemModel([ReciclagemRepository? repo, NuvemRepositorio? nuvem])
      : _repo = repo ?? ReciclagemRepository(),
        _nuvem = nuvem;

  static int _contador = 0;
  final ReciclagemRepository _repo;
  final NuvemRepositorio? _nuvem;
  List<RegistroReciclagem> _registros = [];
  String? _uid;

  List<RegistroReciclagem> get registros => List.unmodifiable(_registros);

  double get totalKg => _registros.fold<double>(0.0, (soma, r) => soma + r.pesoKg);

  /// Quilos registrados no mês de [agora] (o destaque da tela Impacto, RF03).
  double totalDoMes([DateTime? agora]) {
    final hoje = agora ?? DateTime.now();
    return _registros
        .where((r) => r.data.year == hoje.year && r.data.month == hoje.month)
        .fold<double>(0.0, (soma, r) => soma + r.pesoKg);
  }

  Future<void> carregar() async {
    _registros = await _repo.carregar();
    notifyListeners();
  }

  /// Chamado quando o usuário entra ou sai da conta. Com [uid] nulo (visitante
  /// ou sem conta), nada é enviado para a nuvem.
  void definirUsuario(String? uid) => _uid = uid;

  Future<RegistroReciclagem> registrar(String item, double pesoMedioKg) async {
    final registro = RegistroReciclagem(
      id: '${DateTime.now().microsecondsSinceEpoch}_${++_contador}',
      item: item,
      pesoKg: pesoMedioKg,
      data: DateTime.now(),
    );
    _registros.add(registro);
    notifyListeners();
    await _repo.salvar(_registros);
    _enviar(registro);
    return registro;
  }

  Future<void> ajustarPeso(String id, double novoPesoKg) async {
    if (novoPesoKg <= 0) return;
    final index = _registros.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _registros[index] = _registros[index].copyWith(pesoKg: novoPesoKg);
    notifyListeners();
    await _repo.salvar(_registros);
    _enviar(_registros[index]);
  }

  /// Junta o que está no aparelho com o que está na conta: o que só existe de
  /// um lado vai para o outro. Se o mesmo registro existir dos dois lados com
  /// valores diferentes, vale o do aparelho. Chamado ao entrar na conta e
  /// quando a internet volta.
  Future<void> sincronizar() async {
    final uid = _uid;
    final nuvem = _nuvem;
    if (uid == null || nuvem == null || !nuvem.disponivel) return;

    final remotos = {for (final r in await nuvem.lerRegistros(uid)) r.id: r};
    final locais = {for (final r in _registros) r.id: r};

    var mudouLocal = false;
    for (final remoto in remotos.values) {
      if (!locais.containsKey(remoto.id)) {
        _registros.add(remoto);
        mudouLocal = true;
      }
    }
    for (final local in locais.values) {
      if (remotos[local.id] != local) _enviar(local);
    }

    if (mudouLocal) {
      _registros.sort((a, b) => a.data.compareTo(b.data));
      notifyListeners();
      await _repo.salvar(_registros);
    }
  }

  /// Envia um registro sem esperar a resposta do servidor: sem internet, o
  /// Firestore guarda a gravação e envia quando a conexão volta.
  void _enviar(RegistroReciclagem registro) {
    final uid = _uid;
    final nuvem = _nuvem;
    if (uid == null || nuvem == null || !nuvem.disponivel) return;
    unawaited(nuvem.gravarRegistro(uid, registro).catchError((Object e) {
      debugPrint('Registro ${registro.id} não enviado: $e');
    }));
  }
}
