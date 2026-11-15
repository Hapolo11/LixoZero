import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/guia_repository.dart';
import '../data/rotulos_repository.dart';
import '../models/item_guia.dart';
import '../services/reconhecimento_imagem.dart';
import '../theme/app_theme.dart';
import 'comuns.dart';

/// Busca por foto (RF08). O usuário tira ou escolhe uma foto, o app sugere até
/// 3 itens do guia e ele confirma o certo. Devolve o nome do item escolhido
/// (para a tela fazer a busca de sempre), ou null se não houver escolha.
///
/// A foto é analisada no próprio aparelho e não é enviada para lugar nenhum.
Future<String?> buscarPorFoto(BuildContext context) async {
  final origem = await showModalBottomSheet<OrigemFoto>(
    context: context,
    builder: (_) => const _EscolherOrigem(),
  );
  if (origem == null || !context.mounted) return null;

  final seletor = context.read<SeletorFoto>();
  final reconhecedor = context.read<ReconhecedorImagem>();
  final rotulos = context.read<RotulosRepository>();
  final guia = context.read<GuiaRepository>();
  final mensagens = ScaffoldMessenger.of(context);
  final navegador = Navigator.of(context, rootNavigator: true);

  final String? caminho;
  try {
    caminho = await seletor.escolher(origem);
  } catch (_) {
    mensagens.showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir a câmera ou a galeria. Veja a permissão do app e tente de novo.')),
    );
    return null;
  }
  if (caminho == null || !context.mounted) return null;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(canPop: false, child: _Analisando()),
  );

  List<ItemGuia> sugestoes;
  try {
    final encontrados = await reconhecedor.reconhecer(caminho);
    sugestoes = rotulos.sugerir(encontrados, guia);
  } catch (_) {
    navegador.pop();
    mensagens.showSnackBar(
      const SnackBar(content: Text('Não consegui analisar a foto. Digite o nome do resíduo para buscar.')),
    );
    return null;
  }
  navegador.pop();

  if (sugestoes.isEmpty) {
    mensagens.showSnackBar(
      const SnackBar(content: Text('Não reconheci esse resíduo na foto. Digite o nome dele para buscar.')),
    );
    return null;
  }
  if (!context.mounted) return null;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _Sugestoes(itens: sugestoes),
  );
}

class _EscolherOrigem extends StatelessWidget {
  const _EscolherOrigem();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: AppColors.verdeEscuro),
            title: const Text('Tirar uma foto'),
            onTap: () => Navigator.pop(context, OrigemFoto.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.verdeEscuro),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(context, OrigemFoto.galeria),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(
              'A foto é analisada só no seu celular e não é enviada para lugar nenhum.',
              style: TextStyle(fontSize: 13, color: AppColors.textoApoio, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Analisando extends StatelessWidget {
  const _Analisando();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Row(
        children: [
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
          SizedBox(width: 20),
          Expanded(child: Text('Analisando a foto...')),
        ],
      ),
    );
  }
}

class _Sugestoes extends StatelessWidget {
  const _Sugestoes({required this.itens});

  final List<ItemGuia> itens;

  @override
  Widget build(BuildContext context) {
    final guia = context.read<GuiaRepository>();
    final estilos = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text('Parece ser um destes. Qual é?', style: estilos.titleMedium),
          ),
          for (final item in itens)
            ListTile(
              title: Text(item.nome),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: RotuloCategoria(guia.categoria(item.categoriaId)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, item.nome),
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.keyboard_outlined),
            title: const Text('Nenhum desses, vou digitar'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
