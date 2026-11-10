import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/guia_repository.dart';
import 'data/pontos_repository.dart';
import 'data/reciclagem_repository.dart';
import 'services/auth_firebase.dart';
import 'services/auth_repositorio.dart';
import 'services/localizacao_service.dart';
import 'state/auth_model.dart';
import 'state/conexao_model.dart';
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

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: guia),
        Provider.value(value: pontos),
        Provider(create: (_) => LocalizacaoService()),
        ChangeNotifierProvider.value(value: conexao),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: reciclagem),
        ChangeNotifierProvider(create: (_) => NavegacaoModel()),
      ],
      child: const LixoZeroApp(),
    ),
  );
}
