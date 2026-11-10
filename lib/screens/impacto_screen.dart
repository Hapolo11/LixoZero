import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/lembrete.dart';
import '../state/lembretes_model.dart';
import '../state/reciclagem_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

/// Tela Impacto: contador de quilos reciclados (RF03) e lembretes de coleta (RF04).
/// As duas coisas ficam juntas para manter o app em quatro telas (RNF10).
class ImpactoScreen extends StatelessWidget {
  const ImpactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Cabecalho(titulo: 'Seu impacto', pose: Pose.comemorando),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: const [
              ContadorImpacto(),
              SizedBox(height: 24),
              ListaLembretes(),
            ],
          ),
        ),
      ],
    );
  }
}

/// "12,5" / "0,03" / "0": até duas casas, com vírgula.
String formatarKg(double kg) => NumberFormat('#,##0.##', 'pt_BR').format(kg);

class ContadorImpacto extends StatelessWidget {
  const ContadorImpacto({super.key});

  @override
  Widget build(BuildContext context) {
    final reciclagem = context.watch<ReciclagemModel>();
    final doMes = reciclagem.totalDoMes();
    final total = reciclagem.totalKg;
    final quantidade = reciclagem.registros.length;
    final vazio = quantidade == 0;

    return Card(
      color: AppColors.verdeClaro,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
            children: [
              Text(
                '${formatarKg(doMes)} kg',
                key: const Key('contador_mes'),
                style: const TextStyle(
                  fontFamily: fonteNumeros,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              const Text(
                'reciclados este mês',
                style: TextStyle(fontFamily: fonteNumeros, fontSize: 15, color: AppColors.textoApoio),
              ),
              const SizedBox(height: 6),
              Text(
                vazio
                    ? 'Busque um resíduo e toque em "Registrar reciclagem" para começar.'
                    : '"Cada grama conta!"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.texto),
              ),
              if (!vazio) ...[
                const SizedBox(height: 12),
                Text(
                  'Desde o começo: ${formatarKg(total)} kg em $quantidade '
                  '${quantidade == 1 ? 'registro' : 'registros'}',
                  key: const Key('contador_total'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: fonteNumeros, fontSize: 13, color: AppColors.verdeEscuro),
                ),
              ],
            ],
        ),
      ),
    );
  }
}

class ListaLembretes extends StatelessWidget {
  const ListaLembretes({super.key});

  @override
  Widget build(BuildContext context) {
    final lembretes = context.watch<LembretesModel>().lembretes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Lembretes de coleta', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (lembretes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Nenhum lembrete ainda. Crie um para ser avisado no dia da coleta seletiva do seu bairro.',
              style: TextStyle(fontSize: 14, color: AppColors.textoApoio),
            ),
          ),
        for (final lembrete in lembretes) ...[
          CartaoLembrete(lembrete),
          const SizedBox(height: 10),
        ],
        BotaoTracejado(
          texto: 'Novo lembrete',
          aoTocar: () => _criar(context),
        ),
      ],
    );
  }

  Future<void> _criar(BuildContext context) async {
    final dados = await showDialog<DadosLembrete>(
      context: context,
      builder: (_) => const DialogoLembrete(),
    );
    if (dados == null || !context.mounted) return;

    final model = context.read<LembretesModel>();
    await model.criar(hora: dados.hora, minuto: dados.minuto, titulo: dados.titulo, dias: dados.dias);
    if (!context.mounted) return;
    final mensagem = model.avisosPermitidos
        ? 'Lembrete criado!'
        : 'Lembrete salvo, mas as notificações estão desligadas. Ative nas configurações do celular para ser avisado.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class CartaoLembrete extends StatelessWidget {
  const CartaoLembrete(this.lembrete, {super.key});

  final Lembrete lembrete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.verdeMedio,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lembrete.resumo,
                    style: const TextStyle(
                      fontFamily: fonteNumeros,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(lembrete.titulo, style: const TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
            _BotaoQuadrado(
              tooltip: 'Editar lembrete',
              icone: Icons.edit_outlined,
              fundo: const Color(0xFF8EC5FF),
              aoTocar: () => _editar(context),
            ),
            const SizedBox(width: 6),
            _BotaoQuadrado(
              tooltip: 'Apagar lembrete',
              icone: Icons.delete_outline,
              fundo: const Color(0xFFFF5A5A),
              aoTocar: () => _apagar(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context) async {
    final dados = await showDialog<DadosLembrete>(
      context: context,
      builder: (_) => DialogoLembrete(inicial: lembrete),
    );
    if (dados == null || !context.mounted) return;
    await context.read<LembretesModel>().editar(
          lembrete.copyWith(hora: dados.hora, minuto: dados.minuto, titulo: dados.titulo, dias: dados.dias),
        );
  }

  Future<void> _apagar(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => const DialogoConfirmarApagar(),
    );
    if (confirmou != true || !context.mounted) return;
    await context.read<LembretesModel>().excluir(lembrete.id);
  }
}

class _BotaoQuadrado extends StatelessWidget {
  const _BotaoQuadrado({required this.tooltip, required this.icone, required this.fundo, required this.aoTocar});

  final String tooltip;
  final IconData icone;
  final Color fundo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    // 48x48 de área de toque, mesmo com o quadrado visível menor.
    return IconButton(
      tooltip: tooltip,
      onPressed: aoTocar,
      style: IconButton.styleFrom(
        backgroundColor: fundo,
        foregroundColor: AppColors.texto,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      icon: Icon(icone, size: 20),
    );
  }
}

/// Botão com borda tracejada, para ações pouco frequentes ("+ Novo lembrete").
class BotaoTracejado extends StatelessWidget {
  const BotaoTracejado({super.key, required this.texto, required this.aoTocar});

  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    const cantos = BorderRadius.all(Radius.circular(14));
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.branco,
        borderRadius: cantos,
        child: InkWell(
          borderRadius: cantos,
          onTap: aoTocar,
          child: CustomPaint(
            painter: const _BordaTracejada(),
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20, color: AppColors.texto),
                  const SizedBox(width: 6),
                  Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texto)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  const _BordaTracejada();

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColors.texto
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final caminho = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)));
    for (final trecho in caminho.computeMetrics()) {
      for (var d = 0.0; d < trecho.length; d += 9) {
        canvas.drawPath(trecho.extractPath(d, d + 5), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// O que o formulário devolve ao tocar em Criar ou Salvar.
class DadosLembrete {
  const DadosLembrete({required this.hora, required this.minuto, required this.titulo, required this.dias});

  final int hora;
  final int minuto;
  final String titulo;
  final Set<int> dias;
}

/// Janela de "Adicionar Lembrete" ou "Editar Lembrete" (protótipo, página 6).
class DialogoLembrete extends StatefulWidget {
  const DialogoLembrete({super.key, this.inicial});

  final Lembrete? inicial;

  @override
  State<DialogoLembrete> createState() => _DialogoLembreteState();
}

class _DialogoLembreteState extends State<DialogoLembrete> {
  late final TextEditingController _horas;
  late final TextEditingController _minutos;
  late final TextEditingController _titulo;
  late final Set<int> _dias;
  String? _erro;

  bool get _editando => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    final inicial = widget.inicial;
    _horas = TextEditingController(text: inicial?.hora.toString().padLeft(2, '0') ?? '');
    _minutos = TextEditingController(text: inicial?.minuto.toString().padLeft(2, '0') ?? '');
    _titulo = TextEditingController(text: inicial?.titulo ?? '');
    _dias = {...?inicial?.dias};
  }

  @override
  void dispose() {
    _horas.dispose();
    _minutos.dispose();
    _titulo.dispose();
    super.dispose();
  }

  void _confirmar() {
    final hora = int.tryParse(_horas.text.trim());
    final minuto = int.tryParse(_minutos.text.trim());
    final erro = LembretesModel.validar(hora: hora, minuto: minuto, titulo: _titulo.text, dias: _dias);
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    Navigator.of(context).pop(DadosLembrete(hora: hora!, minuto: minuto!, titulo: _titulo.text.trim(), dias: {..._dias}));
  }

  @override
  Widget build(BuildContext context) {
    const rotulo = TextStyle(fontFamily: fonteNumeros, fontSize: 13, color: AppColors.texto);
    final soNumeros = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)];

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
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _editando ? 'Editar Lembrete' : 'Adicionar Lembrete',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('campo_horas'),
                          controller: _horas,
                          keyboardType: TextInputType.number,
                          inputFormatters: soNumeros,
                          style: const TextStyle(fontFamily: fonteNumeros),
                          decoration: const InputDecoration(labelText: 'Horas', hintText: '08'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('campo_minutos'),
                          controller: _minutos,
                          keyboardType: TextInputType.number,
                          inputFormatters: soNumeros,
                          style: const TextStyle(fontFamily: fonteNumeros),
                          decoration: const InputDecoration(labelText: 'Minutos', hintText: '00'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('campo_titulo'),
                    controller: _titulo,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 40,
                    decoration: const InputDecoration(labelText: 'Título', hintText: 'Ex.: Lixo orgânico'),
                  ),
                  for (final dia in Lembrete.nomesDias.entries)
                    CheckboxListTile(
                      key: Key('dia_${dia.key}'),
                      value: _dias.contains(dia.key),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.verdeEscuro,
                      title: Text(dia.value, style: rotulo.copyWith(fontWeight: FontWeight.w600)),
                      onChanged: (marcado) => setState(() {
                        marcado == true ? _dias.add(dia.key) : _dias.remove(dia.key);
                      }),
                    ),
                  if (_erro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _erro!,
                        key: const Key('erro_lembrete'),
                        style: const TextStyle(fontSize: 13, color: Color(0xFFC62828), fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _confirmar,
                    child: Text(_editando ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Certeza que quer apagar?" com X e ✓, como no protótipo.
class DialogoConfirmarApagar extends StatelessWidget {
  const DialogoConfirmarApagar({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.branco,
      content: const Text(
        'Certeza que quer apagar?',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.verdeEscuro),
      ),
      actions: [
        IconButton(
          tooltip: 'Não apagar',
          onPressed: () => Navigator.of(context).pop(false),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF5A5A)),
          icon: const Icon(Icons.close, color: AppColors.texto),
        ),
        IconButton(
          tooltip: 'Apagar',
          onPressed: () => Navigator.of(context).pop(true),
          style: IconButton.styleFrom(backgroundColor: AppColors.verdeMedio),
          icon: const Icon(Icons.check, color: AppColors.texto),
        ),
      ],
    );
  }
}
