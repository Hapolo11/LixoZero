import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dica.dart';
import '../screens/compostagem_screen.dart';
import '../state/dicas_model.dart';
import '../state/navegacao_model.dart';
import '../theme/app_theme.dart';
import 'comuns.dart';

/// Faixa "Dica: compostagem" no rodapé da tela Buscar, como no protótipo.
/// Tocar abre o cartão da dica.
class BarraDica extends StatelessWidget {
  const BarraDica({super.key});

  @override
  Widget build(BuildContext context) {
    final dica = context.watch<DicasModel>().atual;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Material(
        color: AppColors.branco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borda),
        ),
        child: InkWell(
          key: const Key('barra_dica'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => mostrarDica(context, dica),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48), // área de toque mínima
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.verdeEscuro),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dica: ${dica.tema}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texto),
                    ),
                  ),
                  const Icon(Icons.expand_more, color: AppColors.textoApoio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> mostrarDica(BuildContext context, Dica dica) async {
  final acao = await showDialog<_AcaoDica>(context: context, builder: (_) => DialogoDica(dica));
  if (!context.mounted || acao == null) return;

  switch (acao) {
    case _AcaoDica.compostagem:
      abrirCompostagem(context);
    case _AcaoDica.buscar:
      context.read<NavegacaoModel>().buscar(dica.busca!);
  }
}

enum _AcaoDica { compostagem, buscar }

/// Cartão da dica, igual ao do protótipo: faixa verde com o tema, Brotinho,
/// título, texto e "Entendi". Algumas dicas levam ao guia de compostagem
/// ou à busca do item.
class DialogoDica extends StatelessWidget {
  const DialogoDica(this.dica, {super.key});

  final Dica dica;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.branco,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.verdeMedio,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(
                'Dica: ${dica.tema}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: Mascote(Pose.dica, tamanho: 96)),
                  const SizedBox(height: 8),
                  Text(dica.titulo, textAlign: TextAlign.center, style: estilos.titleLarge),
                  const SizedBox(height: 8),
                  Text(dica.texto, textAlign: TextAlign.center, style: estilos.bodyMedium),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Entendi')),
                  if (dica.abreCompostagem) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(_AcaoDica.compostagem),
                      child: const Text('Como compostar em casa'),
                    ),
                  ] else if (dica.busca != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(_AcaoDica.buscar),
                      child: const Text('Ver como descartar'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
