import 'package:flutter/foundation.dart';

import '../data/reciclagem_repository.dart';
import '../models/registro_reciclagem.dart';

/// Guarda os registros de reciclagem salvos no aparelho (RF09).
/// Não coleta dados pessoais e funciona 100% offline.
class ReciclagemModel extends ChangeNotifier {
  ReciclagemModel([ReciclagemRepository? repo]) : _repo = repo ?? ReciclagemRepository();

  static int _contador = 0;
  final ReciclagemRepository _repo;
  List<RegistroReciclagem> _registros = [];

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
    return registro;
  }

  Future<void> ajustarPeso(String id, double novoPesoKg) async {
    if (novoPesoKg <= 0) return;
    final index = _registros.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _registros[index] = _registros[index].copyWith(pesoKg: novoPesoKg);
    notifyListeners();
    await _repo.salvar(_registros);
  }
}

