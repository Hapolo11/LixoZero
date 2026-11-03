import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/guia_repository.dart';
import '../models/categoria.dart';
import '../models/item_guia.dart';
import '../state/navegacao_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

/// Tela "Onde jogo isso?". O fluxo principal tem 3 passos: abrir, digitar e
/// tocar em Buscar. O resultado aparece aqui mesmo.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final _campo = TextEditingController();
  final _foco = FocusNode();
  late final NavegacaoModel _navegacao;

  List<ItemGuia>? _resultados; // null = ainda não buscou nada
  String _ultimaBusca = '';

  static const _duvidasComuns = ['Pilha', 'Caixa de leite', 'Isopor', 'Lâmpada', 'Casca de banana', 'Óleo de cozinha'];

  @override
  void initState() {
    super.initState();
    _navegacao = context.read<NavegacaoModel>();
    _navegacao.addListener(_verBuscaPendente);
    WidgetsBinding.instance.addPostFrameCallback((_) => _verBuscaPendente());
  }

  @override
  void dispose() {
    _navegacao.removeListener(_verBuscaPendente);
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _verBuscaPendente() {
    final termo = _navegacao.pegarBuscaPendente();
    if (termo != null && mounted) _buscar(termo);
  }

  void _buscar(String texto) {
    final busca = texto.trim();
    if (busca.isEmpty) return;

    _campo.text = busca;
    _foco.unfocus();
    final guia = context.read<GuiaRepository>();
    setState(() {
      _ultimaBusca = busca;
      _resultados = guia.busca.buscar(busca, limite: 3).map((r) => r.item).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Cabecalho(titulo: 'Onde jogo isso?', pose: Pose.acenando),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _campo,
                  focusNode: _foco,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _buscar,
                  decoration: const InputDecoration(
                    hintText: 'Digite o resíduo',
                    prefixIcon: Icon(Icons.search, color: AppColors.textoApoio),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: () => _buscar(_campo.text), child: const Text('Buscar')),
            ],
          ),
        ),
        Expanded(child: _conteudo()),
      ],
    );
  }

  Widget _conteudo() {
    final resultados = _resultados;
    if (resultados == null) return _Inicio(sugestoes: _duvidasComuns, aoEscolher: _buscar);
    if (resultados.isEmpty) return _NaoEncontrado(busca: _ultimaBusca);

    final guia = context.read<GuiaRepository>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: resultados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = resultados[i];
        return CartaoResultado(
          item: item,
          categoria: guia.categoria(item.categoriaId),
          destino: guia.destino(item.destino),
        );
      },
    );
  }
}

class CartaoResultado extends StatelessWidget {
  const CartaoResultado({super.key, required this.item, required this.categoria, required this.destino});

  final ItemGuia item;
  final Categoria categoria;
  final String destino;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    // Só faz sentido mostrar o mapa para o que vai para ecoponto ou cooperativa.
    final temPontoDeColeta = item.destino == 'coleta_seletiva' || item.destino == 'ecoponto';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(item.nome, style: estilos.titleLarge)),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(top: 4), child: RotuloCategoria(categoria)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(categoria.icone, size: 16, color: categoria.cor),
                const SizedBox(width: 4),
                Text(categoria.lixeira, style: estilos.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text('INSTRUÇÃO DE DESCARTE', style: estilos.labelSmall),
            const SizedBox(height: 4),
            Text(item.instrucao, style: estilos.bodyLarge),
            const SizedBox(height: 8),
            Text('Destino: $destino', style: estilos.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (temPontoDeColeta) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => context.read<NavegacaoModel>().verPontosDeColeta(item.categoriaId),
                icon: const Icon(Icons.place_outlined, size: 18),
                label: const Text('Ver pontos de coleta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Inicio extends StatelessWidget {
  const _Inicio({required this.sugestoes, required this.aoEscolher});

  final List<String> sugestoes;
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      children: [
        const Center(child: Mascote(Pose.busca, tamanho: 120)),
        const SizedBox(height: 12),
        Text(
          'Digite o nome do resíduo e descubra onde ele vai. Funciona mesmo sem internet.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text('Dúvidas comuns', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in sugestoes)
              ActionChip(
                label: Text(s),
                onPressed: () => aoEscolher(s),
                backgroundColor: AppColors.branco,
                side: const BorderSide(color: AppColors.verdeMedio),
              ),
          ],
        ),
      ],
    );
  }
}

class _NaoEncontrado extends StatelessWidget {
  const _NaoEncontrado({required this.busca});

  final String busca;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      children: [
        const Center(child: Mascote(Pose.busca, tamanho: 110)),
        const SizedBox(height: 12),
        Text('Ainda não conheço "$busca".', textAlign: TextAlign.center, style: estilos.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Tente outro nome (por exemplo, "garrafa" em vez da marca) ou veja os exemplos de cada categoria.',
          textAlign: TextAlign.center,
          style: estilos.bodyMedium,
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () => context.read<NavegacaoModel>().irPara(Aba.categorias),
            child: const Text('Ver categorias'),
          ),
        ),
      ],
    );
  }
}
