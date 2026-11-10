import 'package:lixozero/models/dica.dart';

/// Duas dicas para os testes que montam a tela Buscar: uma que abre o guia de
/// compostagem e outra que procura um item no guia.
const dicasDeTeste = [
  Dica(
    id: 'compostagem',
    tema: 'compostagem',
    titulo: 'Restos de comida viram adubo',
    texto: 'Cascas de frutas, borra de café e cascas de ovo podem virar adubo em casa.',
    abreCompostagem: true,
  ),
  Dica(
    id: 'pet',
    tema: 'embalagens',
    titulo: 'Enxágue antes de separar',
    texto: 'Embalagem limpa tem mais chance de ser reciclada.',
    busca: 'Garrafa PET',
  ),
];
