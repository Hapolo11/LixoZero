import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/guia_repository.dart';
import '../data/pontos_repository.dart';
import '../models/categoria.dart';
import '../models/ponto_coleta.dart';
import '../services/localizacao_service.dart';
import '../state/conexao_model.dart';
import '../state/navegacao_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

/// Ecopontos e cooperativas. Sem internet o mapa some, mas a lista continua,
/// porque os endereços vêm junto com o app.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  GoogleMapController? _mapa;
  Posicao? _posicao;
  FalhaLocalizacao? _falha;
  bool _localizando = true;

  // Orgânico não aparece aqui porque nenhum ponto recebe.
  static const _filtros = ['plastico', 'papel', 'vidro', 'metal', 'perigoso', volumoso];

  @override
  void initState() {
    super.initState();
    _localizar();
  }

  Future<void> _localizar() async {
    setState(() => _localizando = true);
    final resultado = await context.read<LocalizacaoService>().posicaoAtual();
    if (!mounted) return;

    setState(() {
      _posicao = resultado.posicao;
      _falha = resultado.falha;
      _localizando = false;
    });
    final p = resultado.posicao;
    if (p != null) _moverMapa(p.lat, p.lng, 13);
  }

  Future<void> _tentarDeNovo() async {
    await context.read<LocalizacaoService>().abrirConfiguracoes(_falha!);
    if (mounted) await _localizar();
  }

  Future<void> _comoChegar(PontoColeta ponto) async {
    final destino = Uri.encodeComponent('${ponto.endereco}, ${ponto.bairro}, Aracaju - SE');
    final abriu = await launchUrl(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destino'),
      mode: LaunchMode.externalApplication,
    );
    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não consegui abrir o mapa.')));
    }
  }

  void _ligar(String telefone) {
    launchUrl(Uri(scheme: 'tel', path: telefone.replaceAll(RegExp(r'\D'), '')));
  }

  // Sem internet o GoogleMap sai da tela e descarta o controller dele,
  // então só mexe no mapa se ele estiver aparecendo.
  void _moverMapa(double lat, double lng, double zoom) {
    if (!context.read<ConexaoModel>().online) return;
    _mapa?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom));
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConexaoModel>().online;
    final navegacao = context.watch<NavegacaoModel>();
    final guia = context.read<GuiaRepository>();
    final filtro = navegacao.filtroMapa;
    final origem = _posicao ?? centroAracaju;
    final pontos = context.read<PontosRepository>().maisProximos(lat: origem.lat, lng: origem.lng, categoria: filtro);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Cabecalho(titulo: 'Ecopontos próximos', pose: Pose.mapa),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            children: [
              _Filtro(nome: 'Todos', ativo: filtro == null, aoTocar: () => navegacao.filtrarMapa(null)),
              for (final id in _filtros)
                _Filtro(
                  nome: guia.categoria(id).nome,
                  cor: id == volumoso ? null : guia.categoria(id).cor,
                  ativo: filtro == id,
                  aoTocar: () => navegacao.filtrarMapa(id),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              if (online) _mapaGoogle(pontos, origem) else const _SemConexao(),
              const SizedBox(height: 8),
              if (!_localizando && _falha != null) _AvisoLocalizacao(falha: _falha!, aoTocar: _tentarDeNovo),
              if (pontos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum ponto cadastrado recebe esse tipo de resíduo.'),
                ),
              for (final p in pontos)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _CartaoPonto(
                    item: p,
                    mostrarDistancia: !_localizando,
                    aoTocar: online ? () => _moverMapa(p.ponto.lat, p.ponto.lng, 15) : null,
                    aoComoChegar: () => _comoChegar(p.ponto),
                    aoLigar: p.ponto.telefone == null ? null : () => _ligar(p.ponto.telefone!),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Endereços: Prefeitura de Aracaju/Emsurb e cadastro das cooperativas. Confira o horário antes de ir.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapaGoogle(List<PontoComDistancia> pontos, Posicao origem) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 240,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(origem.lat, origem.lng), zoom: 12),
          myLocationEnabled: _posicao != null,
          myLocationButtonEnabled: _posicao != null,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapa = controller,
          markers: {
            for (final p in pontos)
              Marker(
                markerId: MarkerId(p.ponto.id),
                position: LatLng(p.ponto.lat, p.ponto.lng),
                // Verde para cooperativa, azul para ecoponto.
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  p.ponto.ehCooperativa ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
                ),
                infoWindow: InfoWindow(title: p.ponto.nome, snippet: p.ponto.endereco),
              ),
          },
        ),
      ),
    );
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro({required this.nome, required this.ativo, required this.aoTocar, this.cor});

  final String nome;
  final bool ativo;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(nome),
        selected: ativo,
        onSelected: (_) => aoTocar(),
        showCheckmark: false,
        avatar: cor == null ? null : CircleAvatar(backgroundColor: cor, radius: 5),
        backgroundColor: AppColors.branco,
        selectedColor: AppColors.verdeClaro,
        side: BorderSide(color: ativo ? AppColors.verdeEscuro : AppColors.borda),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: ativo ? AppColors.verdeEscuro : AppColors.texto),
      ),
    );
  }
}

class _SemConexao extends StatelessWidget {
  const _SemConexao();

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          const Mascote(Pose.semConexao, tamanho: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sem conexão', style: estilos.titleMedium),
                const SizedBox(height: 4),
                Text('O mapa precisa de internet, mas a lista abaixo continua funcionando.', style: estilos.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoLocalizacao extends StatelessWidget {
  const _AvisoLocalizacao({required this.falha, required this.aoTocar});

  final FalhaLocalizacao falha;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final motivo = switch (falha) {
      FalhaLocalizacao.gpsDesligado => 'A localização do celular está desligada.',
      FalhaLocalizacao.semPermissao => 'O LixoZero não tem permissão para ver sua localização.',
      FalhaLocalizacao.semSinal => 'Não consegui achar sua posição agora.',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(color: AppColors.verdeClaro, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, size: 20, color: AppColors.verdeEscuro),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$motivo As distâncias são a partir do centro de Aracaju.',
              style: const TextStyle(fontSize: 13, color: AppColors.texto),
            ),
          ),
          TextButton(
            onPressed: aoTocar,
            child: Text(falha == FalhaLocalizacao.semSinal ? 'Tentar de novo' : 'Ativar'),
          ),
        ],
      ),
    );
  }
}

class _CartaoPonto extends StatelessWidget {
  const _CartaoPonto({
    required this.item,
    required this.mostrarDistancia,
    required this.aoTocar,
    required this.aoComoChegar,
    required this.aoLigar,
  });

  final PontoComDistancia item;
  final bool mostrarDistancia;
  final VoidCallback? aoTocar;
  final VoidCallback aoComoChegar;
  final VoidCallback? aoLigar;

  @override
  Widget build(BuildContext context) {
    final ponto = item.ponto;
    final estilos = Theme.of(context).textTheme;
    var distancia = 'cerca de ${formatarDistancia(item.distanciaKm)}';
    if (ponto.precisao == 'bairro') distancia += ' (posição aproximada)';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(ponto.nome, style: estilos.titleMedium)),
                  const SizedBox(width: 8),
                  Etiqueta(ponto.ehCooperativa ? 'Cooperativa' : 'Ecoponto', destaque: ponto.ehCooperativa),
                ],
              ),
              const SizedBox(height: 6),
              Text('${ponto.endereco} – ${ponto.bairro}, Aracaju', style: estilos.bodyLarge),
              const SizedBox(height: 2),
              Text(ponto.horario, style: estilos.bodyMedium),
              if (mostrarDistancia) Text(distancia, style: estilos.bodyMedium?.copyWith(fontFamily: fonteNumeros)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: aoComoChegar,
                    icon: const Icon(Icons.directions_outlined, size: 18),
                    label: const Text('Como chegar'),
                  ),
                  if (aoLigar != null)
                    OutlinedButton.icon(
                      onPressed: aoLigar,
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: Text(ponto.telefone!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
