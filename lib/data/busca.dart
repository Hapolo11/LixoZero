import 'dart:math';

import '../models/item_guia.dart';

const _acentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
  'í': 'i', 'î': 'i', 'ì': 'i', 'ï': 'i',
  'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o', 'ö': 'o',
  'ú': 'u', 'û': 'u', 'ù': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

// Palavras que não ajudam a achar o item, como o "de" de "casca de banana".
const _ignorar = {'de', 'da', 'do', 'das', 'dos', 'e', 'a', 'o', 'as', 'os', 'um', 'uma', 'com', 'para', 'em'};

/// Deixa o texto em minúsculas, sem acento, sem pontuação e no singular,
/// para "Pilhas", "pilha" e "PILHA" darem no mesmo.
String normalizar(String texto) {
  final limpo = StringBuffer();
  for (final letra in texto.toLowerCase().split('')) {
    final semAcento = _acentos[letra] ?? letra;
    limpo.write(RegExp(r'[a-z0-9]').hasMatch(semAcento) ? semAcento : ' ');
  }
  return limpo.toString().split(' ').where((p) => p.isNotEmpty).map(_singular).join(' ');
}

String _singular(String palavra) {
  if (palavra.length <= 3) return palavra;
  String semFinal(int letras) => palavra.substring(0, palavra.length - letras);

  if (palavra.endsWith('oes') || palavra.endsWith('aes')) return '${semFinal(3)}ao'; // limões, pães
  if (palavra.endsWith('is') && palavra.length > 4) return '${semFinal(2)}l'; // jornais, papéis
  if (palavra.endsWith('s')) return semFinal(1);
  return palavra;
}

List<String> _palavras(String texto) =>
    texto.split(' ').where((p) => p.isNotEmpty && !_ignorar.contains(p)).toList();

/// Quantas letras precisam mudar para uma palavra virar a outra (Levenshtein).
int distanciaEdicao(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var anterior = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final atual = List<int>.filled(b.length + 1, 0);
    atual[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final custo = a[i - 1] == b[j - 1] ? 0 : 1;
      atual[j] = min(min(atual[j - 1] + 1, anterior[j] + 1), anterior[j - 1] + custo);
    }
    anterior = atual;
  }
  return anterior[b.length];
}

// Palavras maiores aceitam mais erros de digitação.
int _errosAceitos(String palavra) {
  if (palavra.length >= 7) return 2;
  if (palavra.length >= 4) return 1;
  return 0;
}

class ResultadoBusca {
  const ResultadoBusca(this.item, this.pontos);

  final ItemGuia item;
  final int pontos;
}

/// Busca no guia inteiro em memória, então funciona sem internet e responde
/// na hora.
class BuscaGuia {
  BuscaGuia(List<ItemGuia> itens) {
    for (final item in itens) {
      // O nome vem primeiro de propósito: ele vale um pouco mais que os sinônimos.
      _termos[item] = {normalizar(item.nome), ...item.sinonimos.map(normalizar)}.toList();
    }
  }

  final _termos = <ItemGuia, List<String>>{};

  List<ResultadoBusca> buscar(String consulta, {int limite = 5}) {
    final q = normalizar(consulta);
    if (q.isEmpty) return [];
    final palavrasQ = _palavras(q);

    final resultados = <ResultadoBusca>[];
    _termos.forEach((item, termos) {
      var melhor = 0;
      for (var i = 0; i < termos.length; i++) {
        final pontos = _pontuar(q, palavrasQ, termos[i]);
        if (pontos > 0) melhor = max(melhor, pontos + (i == 0 ? 2 : 0));
      }
      if (melhor > 0) resultados.add(ResultadoBusca(item, melhor));
    });
    if (resultados.isEmpty) return [];

    resultados.sort((a, b) => b.pontos.compareTo(a.pontos));

    // Se achou algo bem parecido, descarta os resultados fracos
    // (senão "pilha" traz "palha de aço" junto).
    final minimo = resultados.first.pontos - 40;
    return resultados.where((r) => r.pontos >= minimo).take(limite).toList();
  }

  int _pontuar(String q, List<String> palavrasQ, String termo) {
    if (termo == q) return 100;
    if (q.length >= 3 && termo.startsWith(q)) return 80;
    if (q.length >= 3 && termo.contains(q)) return 65;
    if (termo.length >= 4 && q.contains(termo)) return 60;

    final palavrasT = _palavras(termo);
    if (palavrasQ.isEmpty || palavrasT.isEmpty) return 0;

    // Compara palavra por palavra, aceitando pequenos erros de digitação.
    var achadas = 0;
    var erros = 0;
    for (final pq in palavrasQ) {
      int? menorErro;
      for (final pt in palavrasT) {
        if (pt == pq || (pq.length >= 4 && pt.startsWith(pq))) {
          menorErro = 0;
          break;
        }
        final d = distanciaEdicao(pq, pt);
        if (d <= _errosAceitos(pq) && (menorErro == null || d < menorErro)) menorErro = d;
      }
      if (menorErro != null) {
        achadas++;
        erros += menorErro;
      }
    }

    if (achadas == 0) return 0;
    if (achadas == palavrasQ.length) {
      final pegouTudo = achadas >= palavrasT.length;
      return (pegouTudo ? 55 : 45) - erros * 5;
    }
    return 20 + achadas * 5 - erros * 5;
  }
}
