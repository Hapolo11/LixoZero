import 'package:flutter/material.dart';

import '../state/navegacao_model.dart';
import '../theme/app_theme.dart';

/// Barra de baixo, sempre visível. A aba aberta fica em verde.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key, required this.atual, required this.aoTocar});

  final Aba atual;
  final ValueChanged<Aba> aoTocar;

  static const _itens = [
    (Aba.buscar, Icons.search, 'Buscar'),
    (Aba.mapa, Icons.place_outlined, 'Mapa'),
    (Aba.impacto, Icons.eco_outlined, 'Impacto'),
    (Aba.categorias, Icons.grid_view_outlined, 'Categoria'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            for (final (aba, icone, nome) in _itens)
              Expanded(child: _Item(icone: icone, nome: nome, ativo: aba == atual, aoTocar: () => aoTocar(aba))),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icone, required this.nome, required this.ativo, required this.aoTocar});

  final IconData icone;
  final String nome;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? Colors.white : AppColors.textoApoio;

    return Semantics(
      button: true,
      selected: ativo,
      label: nome,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: aoTocar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ativo ? AppColors.verdeEscuro : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 22, color: cor),
              const SizedBox(height: 2),
              Text(nome, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}
