import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/lembrete.dart';
import '../models/registro_reciclagem.dart';

/// Dados do usuário guardados na nuvem (Firestore). Só quem tem conta usa isto;
/// quem escolhe "Não quero fazer login" fica só com os dados do aparelho.
///
/// Estrutura no Firestore (cada usuário só enxerga o que é dele, ver `firestore.rules`):
///
///     usuarios/{uid}/registros/{id}   item, pesoKg, data
///     usuarios/{uid}/lembretes/{id}   hora, minuto, titulo, dias
abstract class NuvemRepositorio {
  /// false quando o Firebase não foi configurado neste aparelho.
  bool get disponivel;

  Future<List<RegistroReciclagem>> lerRegistros(String uid);

  Future<void> gravarRegistro(String uid, RegistroReciclagem registro);

  Future<List<Lembrete>> lerLembretes(String uid);

  Future<void> gravarLembrete(String uid, Lembrete lembrete);

  Future<void> apagarLembrete(String uid, int id);

  /// Apaga todos os dados do usuário (usado ao excluir a conta).
  Future<void> apagarTudo(String uid);
}

/// Implementação com o Cloud Firestore.
///
/// O Firestore guarda uma cópia local e envia as gravações quando a internet
/// volta, então gravar sem internet não perde nada. Por isso as gravações não
/// esperam a resposta do servidor: o app chama e segue em frente.
class NuvemFirestore implements NuvemRepositorio {
  NuvemFirestore(this._db);

  final FirebaseFirestore _db;

  static const _espera = Duration(seconds: 15);

  @override
  bool get disponivel => true;

  CollectionReference<Map<String, dynamic>> _registros(String uid) =>
      _db.collection('usuarios').doc(uid).collection('registros');

  CollectionReference<Map<String, dynamic>> _lembretes(String uid) =>
      _db.collection('usuarios').doc(uid).collection('lembretes');

  @override
  Future<List<RegistroReciclagem>> lerRegistros(String uid) async {
    final consulta = await _registros(uid).get().timeout(_espera);
    final lista = <RegistroReciclagem>[];
    for (final doc in consulta.docs) {
      final registro = registroDeDocumento(doc.id, doc.data());
      if (registro != null) lista.add(registro);
    }
    return lista;
  }

  @override
  Future<void> gravarRegistro(String uid, RegistroReciclagem registro) {
    return _registros(uid).doc(registro.id).set(documentoDeRegistro(registro));
  }

  @override
  Future<List<Lembrete>> lerLembretes(String uid) async {
    final consulta = await _lembretes(uid).get().timeout(_espera);
    final lista = <Lembrete>[];
    for (final doc in consulta.docs) {
      final lembrete = lembreteDeDocumento(doc.id, doc.data());
      if (lembrete != null) lista.add(lembrete);
    }
    return lista;
  }

  @override
  Future<void> gravarLembrete(String uid, Lembrete lembrete) {
    return _lembretes(uid).doc('${lembrete.id}').set(documentoDeLembrete(lembrete));
  }

  @override
  Future<void> apagarLembrete(String uid, int id) {
    return _lembretes(uid).doc('$id').delete();
  }

  @override
  Future<void> apagarTudo(String uid) async {
    for (final colecao in [_registros(uid), _lembretes(uid)]) {
      final consulta = await colecao.get().timeout(_espera);
      if (consulta.docs.isEmpty) continue;
      final lote = _db.batch();
      for (final doc in consulta.docs) {
        lote.delete(doc.reference);
      }
      await lote.commit().timeout(_espera);
    }
  }
}

/// Registro de reciclagem -> documento do Firestore.
Map<String, dynamic> documentoDeRegistro(RegistroReciclagem r) => {
      'item': r.item,
      'pesoKg': r.pesoKg,
      'data': Timestamp.fromDate(r.data),
    };

/// Documento do Firestore -> registro. Devolve null se o documento estiver
/// incompleto, para um dado ruim não travar o app.
RegistroReciclagem? registroDeDocumento(String id, Map<String, dynamic> dados) {
  try {
    final peso = (dados['pesoKg'] as num).toDouble();
    if (peso <= 0) return null;
    return RegistroReciclagem(
      id: id,
      item: dados['item'] as String,
      pesoKg: peso,
      data: (dados['data'] as Timestamp).toDate(),
    );
  } catch (e) {
    debugPrint('Registro ignorado ($id): $e');
    return null;
  }
}

/// Lembrete -> documento do Firestore.
Map<String, dynamic> documentoDeLembrete(Lembrete l) => {
      'hora': l.hora,
      'minuto': l.minuto,
      'titulo': l.titulo,
      'dias': (l.dias.toList()..sort()),
    };

/// Documento do Firestore -> lembrete (null se estiver incompleto).
Lembrete? lembreteDeDocumento(String id, Map<String, dynamic> dados) {
  try {
    return Lembrete(
      id: int.parse(id),
      hora: dados['hora'] as int,
      minuto: dados['minuto'] as int,
      titulo: dados['titulo'] as String,
      dias: (dados['dias'] as List<dynamic>).cast<int>().toSet(),
    );
  } catch (e) {
    debugPrint('Lembrete ignorado ($id): $e');
    return null;
  }
}

/// Usado quando o Firebase não está configurado: nada vai para a nuvem.
class NuvemIndisponivel implements NuvemRepositorio {
  const NuvemIndisponivel();

  @override
  bool get disponivel => false;

  @override
  Future<List<RegistroReciclagem>> lerRegistros(String uid) async => const [];

  @override
  Future<void> gravarRegistro(String uid, RegistroReciclagem registro) async {}

  @override
  Future<List<Lembrete>> lerLembretes(String uid) async => const [];

  @override
  Future<void> gravarLembrete(String uid, Lembrete lembrete) async {}

  @override
  Future<void> apagarLembrete(String uid, int id) async {}

  @override
  Future<void> apagarTudo(String uid) async {}
}
