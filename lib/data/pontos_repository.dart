import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/ponto_coleta.dart';

// Usado quando não temos a localização do usuário.
const centroAracaju = (lat: -10.9111, lng: -37.0717);

// Para dar prioridade às cooperativas, a distância delas conta como 60% da real.
// Assim uma cooperativa um pouco mais longe passa na frente de um ecoponto,
// mas ninguém é mandado para o outro lado da cidade.
const _pesoCooperativa = 0.6;

class PontoComDistancia {
  const PontoComDistancia(this.ponto, this.distanciaKm);

  final PontoColeta ponto;
  final double distanciaKm;
}

/// Ecopontos e cooperativas (assets/data/pontos.json). A lista vem junto com o
/// app, então aparece mesmo sem internet; só o mapa precisa de conexão.
class PontosRepository {
  PontosRepository(this.pontos);

  final List<PontoColeta> pontos;

  static Future<PontosRepository> carregar() async {
    final json = jsonDecode(await rootBundle.loadString('assets/data/pontos.json'));
    return PontosRepository([for (final p in json['pontos']) PontoColeta.fromJson(p)]);
  }

  List<PontoComDistancia> maisProximos({required double lat, required double lng, String? categoria}) {
    final lista = [
      for (final p in pontos)
        if (categoria == null || p.aceita.contains(categoria))
          PontoComDistancia(p, distanciaKm(lat, lng, p.lat, p.lng)),
    ];

    double ordem(PontoComDistancia p) => p.ponto.ehCooperativa ? p.distanciaKm * _pesoCooperativa : p.distanciaKm;
    lista.sort((a, b) => ordem(a).compareTo(ordem(b)));
    return lista;
  }
}

/// Distância em linha reta entre dois pontos (fórmula de Haversine).
double distanciaKm(double lat1, double lng1, double lat2, double lng2) {
  const raioDaTerra = 6371.0;
  double rad(double graus) => graus * pi / 180;

  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) + cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return raioDaTerra * 2 * atan2(sqrt(a), sqrt(1 - a));
}
