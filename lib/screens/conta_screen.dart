import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/validadores.dart';
import '../services/auth_repositorio.dart';
import '../state/auth_model.dart';
import '../state/sincronizacao_model.dart';
import '../theme/app_theme.dart';
import '../widgets/comuns.dart';

/// Conta opcional: quem entrou vê os dados, edita o nome, sai ou exclui a conta.
/// Quem está sem conta pode voltar para o login daqui.
class ContaScreen extends StatelessWidget {
  const ContaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final usuario = auth.usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Conta'), backgroundColor: AppColors.fundo),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: Mascote(Pose.acenando, tamanho: 96)),
          const SizedBox(height: 12),
          if (usuario == null) ..._visitante(context, auth) else ..._logado(context, auth, usuario),
          const SizedBox(height: 20),
          const _StatusSincronizacao(),
        ],
      ),
    );
  }

  List<Widget> _visitante(BuildContext context, AuthModel auth) {
    return [
      Text('Você está usando o app sem conta', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
        'Tudo funciona normalmente. Se quiser, crie uma conta ou entre.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () async {
          await auth.pedirLogin();
          if (context.mounted) Navigator.of(context).pop();
        },
        child: const Text('Entrar ou criar conta'),
      ),
    ];
  }

  List<Widget> _logado(BuildContext context, AuthModel auth, UsuarioConta usuario) {
    final nome = usuario.nomeExibicao;

    return [
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(nome),
              subtitle: const Text('Nome'),
              trailing: IconButton(
                tooltip: 'Editar nome',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editarNome(context, auth, usuario.nome ?? ''),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(usuario.email),
              subtitle: const Text('E-mail'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => _sair(context, auth),
        icon: const Icon(Icons.logout),
        label: const Text('Sair da conta'),
      ),
      const SizedBox(height: 12),
      TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFB3261E)),
        onPressed: () => _excluir(context, auth),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Excluir minha conta'),
      ),
    ];
  }

  Future<void> _sair(BuildContext context, AuthModel auth) async {
    final navigator = Navigator.of(context);
    await auth.sair();
    navigator.pop();
  }

  Future<void> _editarNome(BuildContext context, AuthModel auth, String atual) async {
    final controller = TextEditingController(text: atual);
    final chave = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);

    final novo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        content: Form(
          key: chave,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nome e sobrenome'),
            validator: (v) => validarNome(v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (chave.currentState?.validate() ?? false) Navigator.pop(ctx, controller.text);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (novo == null) return;

    try {
      await auth.atualizarNome(novo);
      messenger.showSnackBar(const SnackBar(content: Text('Nome atualizado.')));
    } on AuthFalha catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  Future<void> _excluir(BuildContext context, AuthModel auth) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text('Sua conta será apagada e não dá para desfazer. Os dados do app neste aparelho continuam.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir conta'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await auth.excluirConta();
      navigator.pop();
    } on AuthFalha catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }
}

/// Diz onde os dados do usuário estão: só no aparelho (visitante) ou também na
/// conta (Firestore), com o horário da última sincronização.
class _StatusSincronizacao extends StatelessWidget {
  const _StatusSincronizacao();

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SincronizacaoModel>();
    final estilo = Theme.of(context).textTheme.bodyMedium;

    final (icone, texto) = switch (sync.estado) {
      EstadoSincronizacao.semConta => (
          Icons.phone_android,
          'Sem conta, seus registros e lembretes ficam só neste aparelho.',
        ),
      EstadoSincronizacao.aguardandoInternet => (
          Icons.cloud_off_outlined,
          'Sem internet. Seus dados serão enviados para a conta quando a conexão voltar.',
        ),
      EstadoSincronizacao.sincronizando => (Icons.cloud_sync_outlined, 'Sincronizando com a sua conta...'),
      EstadoSincronizacao.sincronizado => (
          Icons.cloud_done_outlined,
          sync.sincronizadoEm == null
              ? 'Dados sincronizados com a sua conta.'
              : 'Dados sincronizados com a sua conta às ${DateFormat.Hm().format(sync.sincronizadoEm!)}.',
        ),
      EstadoSincronizacao.erro => (
          Icons.error_outline,
          'Não foi possível sincronizar agora. Seus dados continuam salvos neste aparelho.',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 20, color: AppColors.textoApoio),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: estilo)),
          ],
        ),
        if (sync.estado == EstadoSincronizacao.erro)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: sync.sincronizarAgora, child: const Text('Tentar de novo')),
          ),
      ],
    );
  }
}
