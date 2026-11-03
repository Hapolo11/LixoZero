import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/pontos_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PontosRepository pontos;

  setUpAll(() async {
    pontos = await PontosRepository.carregar();
  });

  test('tem os 9 ecopontos da Emsurb', () {
    expect(pontos.pontos.where((p) => p.tipo == 'ecoponto'), hasLength(9));
  });

  test('mostra primeiro o ponto mais perto', () {
    // No bairro Industrial, o ecoponto do próprio bairro.
    final lista = pontos.maisProximos(lat: -10.896, lng: -37.052);
    expect(lista.first.ponto.id, 'eco_industrial');
  });

  test('cooperativas têm prioridade sobre ecopontos a uma distância parecida', () {
    // No Santa Maria, a CARE fica a uns 300 m.
    expect(pontos.maisProximos(lat: -10.9919, lng: -37.1032).first.ponto.id, 'coop_care');

    // Aqui o ecoponto está a 300 m e as cooperativas a 330 m: a cooperativa vem antes.
    expect(pontos.maisProximos(lat: -11.0060, lng: -37.0995).first.ponto.id, 'coop_central');
  });

  test('filtra pelo que cada ponto recebe', () {
    final perigosos = pontos.maisProximos(lat: -10.9, lng: -37.07, categoria: 'perigoso');
    expect(perigosos.any((p) => p.ponto.ehCooperativa), isFalse);
    expect(pontos.maisProximos(lat: -10.9, lng: -37.07, categoria: 'organico'), isEmpty);
  });

  test('calcula a distância em km', () {
    // Do centro de Aracaju ao Ecoponto Industrial dá uns 2,8 km.
    expect(distanciaKm(-10.9111, -37.0717, -10.8959452, -37.0516403), closeTo(2.75, 0.1));
  });
}
