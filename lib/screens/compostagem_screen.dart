import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/conteudo_repository.dart';
import '../models/guia_compostagem.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

/// Abre o guia de compostagem por cima da aba atual. Ele não é uma aba nova,
/// porque o app tem no máximo 4 telas principais (RNF10).
void abrirCompostagem(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CompostagemScreen()));
}

/// Conteúdo educativo sobre compostagem doméstica (RF06). Vem dentro do app,
/// então funciona sem internet (RNF03). Abre pela categoria Orgânico, pelo
/// resultado da busca de um item orgânico e pelas dicas do rodapé da busca.
class CompostagemScreen extends StatelessWidget {
  const CompostagemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guia = context.read<ConteudoRepository>().compostagem;
    final estilos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Compostagem em casa'), backgroundColor: AppColors.fundo),
      body: ListView(
        // Soma a barra de gestos do Android para o fim da lista não ficar embaixo dela.
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Row(
            children: [
              const Mascote(Pose.dica, tamanho: 72),
              const SizedBox(width: 12),
              Expanded(child: Text('Restos de comida viram adubo', style: estilos.titleLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(guia.introducao, style: estilos.bodyLarge),
          const SizedBox(height: 16),
          _Secao(
            titulo: 'O que pode ir',
            icone: Icons.check_circle_outline,
            children: [
              Text('RESTOS ÚMIDOS', style: estilos.labelSmall),
              const SizedBox(height: 4),
              for (final item in guia.podeVerdes) _Marcador(item, icone: Icons.check, cor: AppColors.verdeEscuro),
              const SizedBox(height: 10),
              Text('MATERIAL SECO (para cobrir)', style: estilos.labelSmall),
              const SizedBox(height: 4),
              for (final item in guia.podeSecos) _Marcador(item, icone: Icons.check, cor: AppColors.verdeEscuro),
            ],
          ),
          _Secao(
            titulo: 'O que não pode ir',
            icone: Icons.block,
            children: [
              for (final proibido in guia.naoPode)
                _Marcador('${proibido.item}: ${proibido.motivo}.', icone: Icons.close, cor: _vermelho),
            ],
          ),
          _Secao(
            titulo: 'Passo a passo',
            icone: Icons.format_list_numbered,
            children: [
              for (var i = 0; i < guia.passos.length; i++) _Passo(numero: i + 1, texto: guia.passos[i]),
              const SizedBox(height: 4),
              _Destaque(titulo: 'Chorume', texto: guia.chorume),
            ],
          ),
          _Secao(
            titulo: 'Deu problema?',
            icone: Icons.help_outline,
            children: [for (final p in guia.problemas) _Problema(p)],
          ),
          _Secao(
            titulo: 'Sem espaço para composteira?',
            icone: Icons.apartment,
            children: [Text(guia.semEspaco, style: estilos.bodyLarge)],
          ),
        ],
      ),
    );
  }
}

// Vermelho escuro, com contraste acima de 4,5:1 no branco (justificativas, seção 1).
const _vermelho = Color(0xFFC62828);

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.icone, required this.children});

  final String titulo;
  final IconData icone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Row(
                  children: [
                    Icon(icone, size: 20, color: AppColors.verdeEscuro),
                    const SizedBox(width: 8),
                    Expanded(child: Text(titulo, style: Theme.of(context).textTheme.titleMedium)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha de lista com ícone. O ícone é enfeite: o texto já diz se pode ou não.
class _Marcador extends StatelessWidget {
  const _Marcador(this.texto, {required this.icone, required this.cor});

  final String texto;
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ExcludeSemantics(child: Icon(icone, size: 18, color: cor)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({required this.numero, required this.texto});

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.verdeClaro, shape: BoxShape.circle),
            child: Text(
              '$numero',
              style: const TextStyle(fontFamily: fonteNumeros, fontWeight: FontWeight.w600, color: AppColors.verdeEscuro),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Destaque extends StatelessWidget {
  const _Destaque({required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.verdeClaro, borderRadius: BorderRadius.circular(12)),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$titulo: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: texto),
          ],
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _Problema extends StatelessWidget {
  const _Problema(this.problema);

  final ProblemaCompostagem problema;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(problema.problema, style: estilos.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          Text(problema.solucao, style: estilos.bodyMedium),
        ],
      ),
    );
  }
}
