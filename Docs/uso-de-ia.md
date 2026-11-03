# Registro de uso de IA

Este documento registra como a inteligência artificial generativa foi usada no projeto, conforme o item b-vi do Projeto da Unidade II. Cada integrante preenche a própria seção com o que fez, os prompts que funcionaram melhor, os erros que a IA gerou e como foram resolvidos.

A IA foi usada como ferramenta de apoio. O código gerado foi lido, testado no celular e só entrou no repositório depois de funcionar.

## Resumo por integrante

| Integrante | Parte do projeto | Ferramenta de IA |
|---|---|---|
| Hapolo | Login opcional com Firebase, tela de conta e ícone do app | Claude Code |
| Rafael | Sprints 1 e 2 (busca, categorias e mapa) | a preencher |
| Caio | a preencher | a preencher |
| Salatiel | a preencher | a preencher |
| David | a preencher | a preencher |

## Hapolo: login opcional, conta e ícone do app

### O que foi feito com apoio da IA

- Telas de entrar, criar conta e recuperar senha, seguindo o protótipo de alta fidelidade, com o botão "Não quero fazer login".
- Login com e-mail e senha e com Google pelo Firebase Authentication.
- Tela de conta: editar nome, sair e excluir a conta.
- Ícone do app com o Brotinho (ícone adaptativo do Android).
- Testes automáticos das validações, da sessão e da tela de login (`test/login_test.dart`).

### Como o código está organizado

| Arquivo | Função |
|---|---|
| `lib/services/auth_repositorio.dart` | Contrato do login: define o que o app pode pedir (entrar, criar conta, sair, excluir...) sem saber que o Firebase existe. |
| `lib/services/auth_firebase.dart` | Implementação com o Firebase Authentication. Traduz os códigos de erro do Firebase para mensagens em português. Também tem a versão `AuthIndisponivel`, usada quando o Firebase não está configurado. |
| `lib/state/auth_model.dart` | Guarda a sessão (precisa escolher, visitante ou logado) e lembra do "Não quero fazer login" no aparelho. |
| `lib/screens/login_screen.dart` | As três telas do protótipo, com validação dos campos. |
| `lib/screens/conta_screen.dart` | Ver nome e e-mail, editar nome, sair e excluir a conta. |
| `lib/data/validadores.dart` | Regras dos campos: e-mail válido, senha com 6 ou mais caracteres, confirmação igual. |

Duas decisões de projeto:

- O app só conversa com o `AuthRepositorio`. Por isso os testes usam um login de mentira e rodam sem internet e sem Firebase.
- O login é opcional (RNF06). Se o `google-services.json` não estiver no projeto, o app abre normalmente, o login mostra um aviso e "Não quero fazer login" continua funcionando.

### Bibliotecas escolhidas

| Biblioteca | Por que foi escolhida |
|---|---|
| `firebase_core` e `firebase_auth` | O enunciado exige Firebase para autenticação. O `firebase_auth` já traz e-mail e senha, recuperação de senha, exclusão de conta e login com Google sem precisar de outro pacote. |
| `shared_preferences` | Guardar no aparelho uma única informação simples (se o usuário escolheu seguir sem login). Não justifica um banco de dados. |
| Plugin Gradle `com.google.gms.google-services` | Lê o `google-services.json` e liga o app ao projeto do Firebase. Só é aplicado se o arquivo existir. |

O login com Google usa `signInWithProvider(GoogleAuthProvider())`, do próprio `firebase_auth`, e não o pacote `google_sign_in`, para ter uma dependência a menos.

### Erros gerados pela IA e como foram resolvidos

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| App em tela preta ao abrir | O `shared_preferences` 2.5.x usa a biblioteca nativa `libdartjni.so`, que não entrava no APK. O `SharedPreferences.getInstance()` falhava antes do `runApp`. Foi visto no log do celular (`Failed to load dynamic library at path: libdartjni.so`). | `shared_preferences_android` fixado na versão 2.4.28 em `dependency_overrides`, com comentário no `pubspec.yaml`. Também foi preciso desinstalar o app e recompilar, porque a parte nativa antiga continuava instalada. |
| Login do Google não funcionava | O `google-services.json` foi baixado antes de registrar o SHA-1 e de ativar o Google no console, então não tinha cliente OAuth (`oauth_client` vazio). | SHA-1 do certificado de debug registrado no console, Google ativado, `google-services.json` baixado de novo e app recompilado. |
| Nome não aparecia no perfil depois de criar a conta | O nome era salvo no Firebase, mas o app lia o usuário antes de o dado voltar do servidor. | Chamada de `reload()` depois de `updateDisplayName`. Se não houver nome, o perfil mostra o começo do e-mail. |
| App não compilava com o Flutter 3.47.1 | O `pubspec.yaml` do projeto exige Dart `^3.13.7`, e o Flutter instalado tinha o Dart 3.13.1. | `flutter upgrade` para o 3.47.9. |
| Falha de Kotlin ao compilar (`Could not close incremental caches`) | Problema do compilador Kotlin quando o projeto e o cache ficam em discos diferentes (C: e D:). | `kotlin.incremental=false` no `gradle.properties` do usuário, fora do repositório. |
| Emulador não abria | O AVD fica no disco C:, que estava sem os 12 GB livres que ele exige. | Os testes passaram a ser feitos num celular Android real, por cabo USB. |

### Decisão sobre o `google-services.json` no repositório

A IA sugeriu commitar o `android/app/google-services.json`, porque sem ele o app não liga ao Firebase e o login não funciona na máquina de quem corrige. Depois do push, o grupo percebeu que o arquivo traz uma chave de API (`AIzaSy...`) e que o repositório é público, e a decisão foi revista.

- **O que é a chave:** identifica o app Android para o Firebase e vai dentro de qualquer APK. Não é uma chave de servidor nem uma senha. Quem protege os dados são as regras de segurança do Firebase, e não o sigilo desse arquivo, e a documentação do Firebase permite versionar o `google-services.json`.
- **O que não foi para o GitHub:** a chave do Google Maps, que continua só no `android/local.properties`, fora do Git.
- **Decisão:** manter o arquivo no repositório, para o app funcionar na correção. No Google Cloud Console foi conferido que a chave criada pelo Firebase já vem restrita a 25 APIs do próprio Firebase (entre elas Identity Toolkit, Token Service, Firebase Installations e Cloud Firestore), e não a qualquer serviço do Google. Não foi feita restrição por SHA-1 (aplicativo), porque ela bloquearia o login em qualquer computador com outro certificado de debug, como o da professora.
- **Não foi reescrito o histórico do Git:** exigiria `git push --force` no branch compartilhado, com risco de apagar trabalho dos colegas, e a chave não é um segredo de fato.
- **Próximo cuidado:** ao criar o Firestore, não deixar as regras em modo de teste aberto.

### Prompts que funcionaram melhor

Resumo dos pedidos que levaram a um resultado direto, na ordem em que foram feitos.

1. **Implementação do login opcional.** Implementar a autenticação opcional do aplicativo com Firebase Authentication, seguindo o protótipo de alta fidelidade e os requisitos do projeto, com a opção de acessar o aplicativo sem login.
   Resultado: a IA leu o código do Rafael, o protótipo e os requisitos antes de escrever as telas, o modelo de sessão e os testes.
2. **Diagnóstico da tela preta.** Analisar o log do `flutter run` e o log do aparelho para identificar por que o aplicativo permanecia em uma tela preta ao ser aberto.
   Resultado: o log do celular revelou a falha ao carregar `libdartjni.so`, o que levou a fixar a versão do `shared_preferences_android`.
3. **Falha no login com Google.** Verificar a configuração do Firebase e do projeto Android, porque o login com a conta Google não funcionava no dispositivo.
   Resultado: a conferência do `google-services.json` mostrou que o arquivo não tinha cliente OAuth, e ele foi baixado de novo depois de registrar o SHA-1.
4. **Nome ausente no perfil.** Corrigir o campo de nome da tela de conta, que não era preenchido após criar uma conta com e-mail e senha.
   Resultado: a IA descreveu o sintoma e a causa (usuário lido antes da atualização do perfil) e corrigiu com `reload()` e um nome alternativo tirado do e-mail.
5. **Ícone do aplicativo.** Criar o ícone do aplicativo a partir do mascote Brotinho, no formato adaptativo do Android.
   Resultado: a IA gerou o ícone em todas as densidades de tela, com o mascote dentro da área segura.

Observação geral: descrever o sintoma que aparece na tela e fornecer o log do dispositivo produziu resultados melhores do que pedir uma correção sem contexto.

### Como o resultado foi conferido

- `flutter analyze` sem problemas e todos os testes passando (31 no momento deste registro).
- Teste no celular real (Android 15): criar conta, entrar, sair, editar nome, senha errada, recuperar senha, excluir conta, "Não quero fazer login" e login com Google.
- Leitura do log do celular (`adb logcat`) para confirmar que o Firebase notificava o login e o logout e que não havia exceções.

## Rafael: sprints 1 e 2 (busca, categorias e mapa)

A preencher por Rafael: o que foi feito com apoio de IA, os prompts mais eficientes, os erros gerados e como foram resolvidos, e a justificativa das bibliotecas (`provider`, `google_maps_flutter`, `geolocator`, `connectivity_plus`, `url_launcher`, `intl`).

## Caio

A preencher por Caio.

## Salatiel

A preencher por Salatiel.

## David

A preencher por David.
