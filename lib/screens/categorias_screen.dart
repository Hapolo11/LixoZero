import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/guia_repository.dart';
import '../models/categoria.dart';
import '../state/navegacao_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';
import 'compostagem_screen.dart';

/// Todas as categorias numa rolagem só, para dar para comparar sem ficar tocando.
class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = context.read<GuiaRepository>().categorias;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Cabecalho(titulo: 'Classificação de resíduos', pose: Pose.dica),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            itemCount: categorias.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _CartaoCategoria(categorias[i]),
          ),
        ),
      ],
    );
  }
}

class _CartaoCategoria extends StatelessWidget {
  const _CartaoCategoria(this.categoria);

  final Categoria categoria;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: categoria.cor, width: 5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wrap em vez de Row: com a fonte grande do sistema, a lixeira desce
            // para a linha de baixo em vez de estourar a tela.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                RotuloCategoria(categoria, tamanho: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 20, color: categoria.cor),
                    const SizedBox(width: 4),
                    Text(categoria.lixeira, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.texto)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(categoria.descricao, style: estilos.bodyLarge),
            const SizedBox(height: 10),
            Text('EXEMPLOS (toque para ver como descartar)', style: estilos.labelSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final exemplo in categoria.exemplos)
                  ActionChip(
                    avatar: Icon(categoria.icone, size: 16, color: categoria.cor),
                    label: Text(exemplo),
                    backgroundColor: AppColors.fundo,
                    side: const BorderSide(color: AppColors.borda),
                    onPressed: () => context.read<NavegacaoModel>().buscar(exemplo),
                  ),
              ],
            ),
            // RF06: a compostagem fica dentro do Orgânico, sem aba nova (RNF10).
            if (categoria.id == 'organico') ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => abrirCompostagem(context),
                icon: const Icon(Icons.eco_outlined, size: 18),
                label: const Text('Aprenda a compostar em casa'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
