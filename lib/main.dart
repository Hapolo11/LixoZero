import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/conteudo_repository.dart';
import 'data/guia_repository.dart';
import 'data/lembretes_repository.dart';
import 'data/pontos_repository.dart';
import 'data/reciclagem_repository.dart';
import 'services/auth_firebase.dart';
import 'services/auth_repositorio.dart';
import 'services/localizacao_service.dart';
import 'services/notificacoes.dart';
import 'state/auth_model.dart';
import 'state/conexao_model.dart';
import 'state/dicas_model.dart';
import 'state/lembretes_model.dart';
import 'state/navegacao_model.dart';
import 'state/reciclagem_model.dart';

/// Liga o Firebase. Se o arquivo google-services.json não estiver no projeto,
/// o app abre mesmo assim, só com o login indisponível (e "Não quero fazer login").
Future<AuthRepositorio> _iniciarFirebase() async {
  try {
    await Firebase.initializeApp();
    return AuthFirebase(FirebaseAuth.instance);
  } catch (e) {
    debugPrint('Firebase não configurado: $e');
    return const AuthIndisponivel();
  }
}

/// Liga as notificações dos lembretes. Se falhar, os lembretes continuam
/// salvos e aparecem na tela, só não tocam.
Future<Notificacoes> _iniciarNotificacoes() async {
  try {
    final notificacoes = NotificacoesLocais();
    await notificacoes.iniciar();
    return notificacoes;
  } catch (e) {
    debugPrint('Notificações indisponíveis: $e');
    return const NotificacoesDesligadas();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final guia = await GuiaRepository.carregar();
  final pontos = await PontosRepository.carregar();
  final conexao = ConexaoModel();
  await conexao.iniciar();
  final prefs = await SharedPreferences.getInstance();
  final auth = AuthModel(await _iniciarFirebase(), prefs);
  final reciclagemRepo = ReciclagemRepository(prefs);
  final reciclagem = ReciclagemModel(reciclagemRepo);
  await reciclagem.carregar();
  final lembretes = LembretesModel(LembretesRepository(prefs), await _iniciarNotificacoes());
  await lembretes.carregar();
  final conteudo = await ConteudoRepository.carregar();
  final dicas = DicasModel(conteudo.dicas, prefs);
  await dicas.carregar();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: guia),
        Provider.value(value: pontos),
        Provider.value(value: conteudo),
        Provider(create: (_) => LocalizacaoService()),
        ChangeNotifierProvider.value(value: conexao),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: reciclagem),
        ChangeNotifierProvider.value(value: lembretes),
        ChangeNotifierProvider.value(value: dicas),
        ChangeNotifierProvider(create: (_) => NavegacaoModel()),
      ],
      child: const LixoZeroApp(),
    ),
  );
}
