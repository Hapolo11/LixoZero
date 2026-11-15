import 'package:flutter_test/flutter_test.dart';
import 'package:lixozero/data/busca.dart';
import 'package:lixozero/data/guia_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GuiaRepository guia;

  setUpAll(() async {
    guia = await GuiaRepository.carregar();
  });

  String? primeiroResultado(String busca) {
    final resultados = guia.busca.buscar(busca);
    return resultados.isEmpty ? null : resultados.first.item.id;
  }

  test('normalizar tira acento, maiúsculas e plural', () {
    expect(normalizar('Lâmpadas'), 'lampada');
    expect(normalizar('  ÓLEO de cozinha! '), 'oleo de cozinha');
    expect(normalizar('Jornais'), 'jornal');
    expect(normalizar('Papéis'), 'papel');
  });

  test('acha pelo nome e pelos sinônimos', () {
    expect(primeiroResultado('pilha'), 'pilha');
    expect(primeiroResultado('Casca de banana'), 'casca_banana');
    expect(primeiroResultado('caixa de leite'), 'caixa_leite');
    expect(primeiroResultado('longa vida'), 'caixa_leite');
    expect(primeiroResultado('latinha'), 'lata_aluminio');
    expect(primeiroResultado('garrafa pet'), 'garrafa_pet');
  });

  test('aceita plural, falta de acento e erro de digitação', () {
    expect(primeiroResultado('pilhas'), 'pilha');
    expect(primeiroResultado('lampada'), 'lampada_fluorescente');
    expect(primeiroResultado('oleo'), 'oleo_cozinha');
    expect(primeiroResultado('isoppor'), 'isopor');
    expect(primeiroResultado('garafa pet'), 'garrafa_pet');
  });

  test('acha enquanto a pessoa ainda está digitando', () {
    expect(primeiroResultado('remed'), 'medicamento');
  });

  test('um resultado certo não vem junto com parecidos fracos', () {
    final ids = guia.busca.buscar('pilha').map((r) => r.item.id);
    expect(ids, isNot(contains('esponja')));
  });

  test('não inventa resultado', () {
    expect(guia.busca.buscar('xyzw'), isEmpty);
    expect(guia.busca.buscar('   '), isEmpty);
  });

  test('a busca é rápida (bem menos que os 3 segundos do requisito)', () {
    final cronometro = Stopwatch()..start();
    for (var i = 0; i < 100; i++) {
      guia.busca.buscar('garrafa de vidro');
    }
    expect(cronometro.elapsedMilliseconds / 100, lessThan(50));
  });

  test('o guia tem as 6 categorias da coleta seletiva', () {
    expect(guia.categorias.map((c) => c.id), ['plastico', 'papel', 'vidro', 'metal', 'organico', 'perigoso']);
  });

  test('todo item do guia está completo', () {
    final ids = <String>{};
    for (final item in guia.itens) {
      expect(ids.add(item.id), isTrue, reason: 'id repetido: ${item.id}');
      expect(() => guia.categoria(item.categoriaId), returnsNormally, reason: item.id);
      expect(guia.destinos.containsKey(item.destino), isTrue, reason: item.id);
      expect(item.pesoKg, greaterThan(0), reason: item.id);
      expect(item.instrucao, isNotEmpty, reason: item.id);
    }
  });
}
