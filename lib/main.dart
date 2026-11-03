import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/guia_repository.dart';
import 'data/pontos_repository.dart';
import 'services/localizacao_service.dart';
import 'state/conexao_model.dart';
import 'state/navegacao_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final guia = await GuiaRepository.carregar();
  final pontos = await PontosRepository.carregar();
  final conexao = ConexaoModel();
  await conexao.iniciar();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: guia),
        Provider.value(value: pontos),
        Provider(create: (_) => LocalizacaoService()),
        ChangeNotifierProvider.value(value: conexao),
        ChangeNotifierProvider(create: (_) => NavegacaoModel()),
      ],
      child: const LixoZeroApp(),
    ),
  );
}
