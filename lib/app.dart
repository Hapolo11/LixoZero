import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/buscar_screen.dart';
import 'screens/categorias_screen.dart';
import 'screens/impacto_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mapa_screen.dart';
import 'state/auth_model.dart';
import 'state/navegacao_model.dart';
import 'theme/app_theme.dart';
import 'widgets/barra_navegacao.dart';

class LixoZeroApp extends StatelessWidget {
  const LixoZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LixoZero',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      themeMode: ThemeMode.light, // o app é só no modo claro
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _Raiz(),
    );
  }
}

/// Mostra o login até o usuário escolher entrar ou seguir sem conta.
class _Raiz extends StatelessWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<AuthModel>().sessao;
    return sessao == Sessao.precisaEscolher ? const LoginScreen() : const TelaPrincipal();
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // As telas só são montadas na primeira vez que o usuário abre a aba.
  // Assim o app abre mais rápido e a permissão de localização só é pedida
  // quando ele entra no Mapa.
  final _abertas = <Aba>{Aba.buscar};

  Widget _tela(Aba aba) {
    switch (aba) {
      case Aba.buscar:
        return const BuscarScreen();
      case Aba.mapa:
        return const MapaScreen();
      case Aba.impacto:
        return const ImpactoScreen();
      case Aba.categorias:
        return const CategoriasScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navegacao = context.watch<NavegacaoModel>();
    _abertas.add(navegacao.aba);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: navegacao.aba.index,
          children: [
            for (final aba in Aba.values) _abertas.contains(aba) ? _tela(aba) : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: BarraNavegacao(atual: navegacao.aba, aoTocar: navegacao.irPara),
    );
  }
}
