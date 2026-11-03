import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/categoria.dart';
import '../state/conexao_model.dart';
import '../theme/app_theme.dart';

// Poses do Brotinho, tiradas do protótipo de alta fidelidade.
enum Pose { acenando, comemorando, dica, busca, mapa, semConexao }

const _imagensMascote = {
  Pose.acenando: 'assets/images/brotinho_acenando.png',
  Pose.comemorando: 'assets/images/brotinho_comemorando.png',
  Pose.dica: 'assets/images/brotinho_dica.png',
  Pose.busca: 'assets/images/brotinho_busca.png',
  Pose.mapa: 'assets/images/brotinho_mapa.png',
  Pose.semConexao: 'assets/images/brotinho_sem_conexao.png',
};

class Mascote extends StatelessWidget {
  const Mascote(this.pose, {super.key, this.tamanho = 56});

  final Pose pose;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    // O mascote é só enfeite: tudo o que ele "diz" também aparece em texto.
    return Image.asset(
      _imagensMascote[pose]!,
      width: tamanho,
      height: tamanho,
      excludeFromSemantics: true,
    );
  }
}

/// Topo das telas principais: aviso de offline, mascote e título.
class Cabecalho extends StatelessWidget {
  const Cabecalho({super.key, required this.titulo, required this.pose});

  final String titulo;
  final Pose pose;

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConexaoModel>().online;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(online ? Icons.wifi : Icons.wifi_off, size: 16, color: AppColors.verdeEscuro),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  online ? 'offline disponível' : 'sem internet · o guia funciona assim mesmo',
                  style: const TextStyle(fontSize: 13, color: AppColors.verdeEscuro, fontWeight: FontWeight.w500),
                ),
              ),
              Mascote(pose, tamanho: 52),
            ],
          ),
          Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

/// Bolinha com a cor da categoria + o nome escrito, para não depender só da cor.
class RotuloCategoria extends StatelessWidget {
  const RotuloCategoria(this.categoria, {super.key, this.tamanho = 13});

  final Categoria categoria;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: categoria.cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          categoria.nome,
          style: TextStyle(fontSize: tamanho, fontWeight: FontWeight.w600, color: AppColors.texto),
        ),
      ],
    );
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.destaque = false});

  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: destaque ? AppColors.verdeEscuro : AppColors.verdeClaro,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: destaque ? Colors.white : AppColors.verdeEscuro,
        ),
      ),
    );
  }
}

/// "850 m" ou "2,3 km".
String formatarDistancia(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${NumberFormat('#,##0.0', 'pt_BR').format(km)} km';
}
