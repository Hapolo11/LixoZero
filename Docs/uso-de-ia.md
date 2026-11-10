# Registro de uso de IA

Este documento registra como a inteligência artificial generativa foi usada no projeto, conforme o item b-vi do Projeto da Unidade II. Cada integrante preenche a própria seção com o que fez, os prompts que funcionaram melhor, os erros que a IA gerou e como foram resolvidos.

A IA foi usada como ferramenta de apoio. O código gerado foi lido, testado no celular e só entrou no repositório depois de funcionar.

## Resumo por integrante

| Integrante | Parte do projeto | Ferramenta de IA |
|---|---|---|
| Hapolo | Login opcional com Firebase, tela de conta e ícone do app | Claude Code |
| Rafael | Sprints 1, 2 e 3 (busca, categorias, mapa, contador de impacto e lembretes) | Claude Code |
| Caio | a preencher | a preencher |
| Salatiel | Sprint 3 (registro de reciclagem, tela Impacto e lembretes de coleta) | Agente do Antigravity e Claude |
| David | Sprint 4 (guia de compostagem e dica rotativa da tela Buscar) | Claude Code |

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

## Rafael: sprints 1, 2 e 3 (busca, categorias, mapa e tela Impacto)

### O que foi feito com apoio da IA

- Correção das inconsistências da documentação antes de começar o código: categoria Metal incluída (os requisitos tinham 5 categorias e o protótipo usava 6), RF09 reescrito para o registro só acontecer ao tocar em "Registrar reciclagem", tabela CRUD ajustada e priorização revista (guia offline junto com a busca, login por último, RF11 e RF12 fora do protótipo).
- Instalação do ambiente no Mac: Flutter 3.47.9, JDK 21, Android SDK com emulador, Xcode com simulador de iPhone, CocoaPods e as extensões Flutter e Dart do VS Code.
- **Sprint 1:** projeto Flutter, tema com a paleta e as fontes do protótipo, navegação com as 4 abas e o mascote Brotinho, guia de classificação com 6 categorias e 81 itens e a tela "Onde jogo isso?" com busca offline (RF01, RF05).
- **Sprint 2:** tela de categorias com código de cores (RF07), mapa dos ecopontos e cooperativas de Aracaju com localização, distância, filtros, "Como chegar" e "Ligar" (RF02) e aviso de sem internet (RF10).
- **Sprint 3:** tela Impacto com o contador de quilos reciclados no mês e desde o começo (RF03) e lembretes de coleta seletiva com criar, ver, editar e apagar, que tocam uma notificação semanal no dia e horário escolhidos (RF04).
- Correção de um erro no aviso "Registrado!" da RF09, que não sumia e cobria as outras abas.
- Testes automáticos da busca, dos pontos de coleta, do contador, dos lembretes e das notificações.

### Como o código está organizado

| Arquivo | Função |
|---|---|
| `assets/data/guia.json` | Guia com as 6 categorias e os 81 itens: instrução de descarte, destino, sinônimos e peso médio estimado de cada um. |
| `assets/data/pontos.json` | Os 9 ecopontos da Emsurb e as cooperativas CARE, Coores e União, com endereço, horário, telefone e coordenadas. |
| `lib/data/busca.dart` | Busca no guia inteiro em memória. Ignora acento, plural e maiúsculas e aceita pequenos erros de digitação. |
| `lib/screens/buscar_screen.dart` | Tela "Onde jogo isso?": campo de busca, dúvidas comuns, resultado e "não encontrei". |
| `lib/screens/categorias_screen.dart` | As 6 categorias com cor, lixeira e exemplos. Tocar num exemplo abre a busca. |
| `lib/screens/mapa_screen.dart` | Mapa e lista de pontos, ordenados pela distância, com filtros por categoria. |
| `lib/services/localizacao_service.dart` | Pede a localização e explica o motivo quando ela falha (GPS desligado, sem permissão ou sem sinal). A posição não é salva. |
| `lib/state/conexao_model.dart` | Avisa as telas quando a internet cai ou volta. |
| `lib/screens/impacto_screen.dart` | Tela Impacto: contador, lista de lembretes e as janelas de adicionar, editar e apagar do protótipo. |
| `lib/state/lembretes_model.dart` | Regras dos lembretes: valida os campos, salva no aparelho e mantém as notificações em dia com a lista. |
| `lib/services/notificacoes.dart` | Agenda as notificações semanais. Também tem a versão `NotificacoesDesligadas`, usada se o sistema de notificações falhar. |

Três decisões de projeto:

- **Offline first (RNF03):** o guia vem dentro do app e a busca roda no próprio celular, por isso responde na hora mesmo sem internet. Só o mapa depende de conexão.
- **Nada pessoal sai do aparelho (RNF06 e RNF07):** a localização só serve para ordenar os pontos e não é guardada; o contador e os lembretes ficam salvos só no celular.
- **Notificações atrás de uma interface:** a tela só conversa com `Notificacoes`, igual ao `AuthRepositorio` do login. Os testes usam uma versão falsa e rodam sem depender do sistema do celular.

### Bibliotecas escolhidas

| Biblioteca | Por que foi escolhida |
|---|---|
| `provider` | Gerencia o estado (aba aberta, conexão, registros, lembretes) de forma simples. É a opção recomendada pela documentação do Flutter para apps deste tamanho. |
| `google_maps_flutter` | O RNF13 define o Google Maps como serviço de mapas. |
| `geolocator` | Pega a posição e diferencia GPS desligado de permissão negada, para o aviso dizer a causa certa. |
| `connectivity_plus` | Detecta quando a internet cai, para mostrar o aviso do RF10 e manter a lista de pontos visível. |
| `url_launcher` | Abre o "Como chegar" no app de mapas e o "Ligar" no discador, sem reimplementar nada. |
| `intl` | Formata números no padrão brasileiro ("2,3 km", "12,5 kg"). |
| `flutter_local_notifications` | Agenda as notificações dos lembretes no próprio celular, sem servidor, o que mantém o app offline. |
| `timezone` e `flutter_timezone` | A notificação semanal precisa do fuso do aparelho para tocar na hora certa. |
| `shared_preferences` | Já estava no projeto (login). Os lembretes são poucos dados simples e não justificam um banco de dados. |

### Erros gerados pela IA e como foram resolvidos

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| Buscar "pilha" trazia "Esponja de cozinha" junto | A busca aceita erros de digitação, e "palha" (de "palha de aço", sinônimo da esponja) tem só uma letra de diferença de "pilha". Foi visto testando no emulador. | Quando a busca acha um resultado bem parecido, descarta os resultados fracos. Virou teste em `test/busca_test.dart`. |
| Mapa dizia "sem acesso à localização" com a permissão concedida | O problema não era permissão: o GPS do emulador não entregava a posição. O aviso juntava todas as falhas numa mensagem só. | O aviso passou a dizer o motivo certo (localização desligada, sem permissão ou sem sinal), com o botão adequado para cada caso. No emulador, a posição foi simulada no centro de Aracaju. |
| Erro no mapa ao perder a internet | A tela continuava guardando o mapa antigo. Se a localização chegasse nesse momento, o app tentava mover um mapa que já tinha saído da tela, e o mapa era descartado duas vezes. Achado na revisão do código. | A tela deixa de usar o mapa quando a internet cai e só o descarta uma vez. |
| App não compilava no Android depois de instalar as notificações | A versão 23 do `flutter_local_notifications` exige o Android SDK 37, e o projeto usa o 36. Mudar o build afetaria o grupo inteiro. | O pacote ficou na versão 22, que funciona com o SDK 36 e tem a mesma forma de uso. Também foi ligado o desugaring no `build.gradle.kts`, que o pacote exige. |
| Testes dos lembretes não carregavam | O fuso horário era lido antes de o banco de fusos ser iniciado no teste. | O banco de fusos passou a ser iniciado no começo do arquivo de teste. |
| Aviso de coleta podia chegar 1 hora atrasado | A IA tinha usado o alarme inexato do Android, que não exige permissão. No emulador, o Android deu a ele uma janela de 1 hora, então o aviso das 08:00 podia chegar depois do caminhão. | O app usa o alarme exato quando o Android permite e só cai para o inexato quando não permite (Android 14 ou mais novo sem a opção "Alarmes e lembretes"). Explicado no README. |
| Ícone da notificação aparecia como um círculo vazio | O Android exige um ícone de uma cor só na barra de notificações, e o ícone colorido do app virava só uma silhueta. | Ícone de folha em vetor (`ic_notificacao.xml`), com um `keep.xml` para o build de release não removê-lo. |
| Aviso "Registrado!" não sumia | Desde o Flutter 3.29, um SnackBar com botão de ação fica na tela até ser fechado. O aviso da RF09 cobria a tela Impacto. Achado testando a sprint 3 no emulador. | `persist: false` no SnackBar e um teste que confere que ele some sozinho. O teste falha sem a correção. |
| Pedido de permissão de notificação parecia não aparecer | No emulador, a janela do Android demorava vários segundos para abrir, e o lembrete só confirmava depois da resposta. | Não era erro do app. Foi conferido no log e no estado da permissão (`adb shell dumpsys`). Se o usuário negar, o app agora avisa que o lembrete fica salvo, mas não vai tocar. |

### Dados reais e chave do Google Maps

- **Ecopontos:** os 9 de Aracaju vêm da Prefeitura/Emsurb (revista Conviver, ed. 748, de 23/09/2025), e o horário vem do TRE-SE. Quatro endereços não têm número, então o app mostra "posição aproximada".
- **Cooperativas:** CARE, Coores e União, com endereço tirado do cadastro de CNPJ da Receita Federal. O horário não foi encontrado, então o app mostra "Ligue antes de ir".
- **Coordenadas:** OpenStreetMap (Nominatim). Algumas são o centro da rua ou do bairro.
- **Pesos médios dos 81 itens:** estimativas feitas para o projeto. Precisam de conferência do grupo.
- **Chave do Google Maps:** criada no Google Cloud Console, restrita ao pacote do app e à Maps SDK, com chaves separadas para Android e iOS. Fica em `android/local.properties` e `ios/Flutter/Secrets.xcconfig`, que o Git ignora; antes de cada envio foi conferido que esses arquivos não iam junto.

### Prompts que funcionaram melhor

Resumo dos pedidos que levaram a um resultado direto, na ordem em que foram feitos.

1. **Início das sprints.** Corrigir todas as inconsistências da documentação, registrando cada decisão no CHANGELOG, incluir a categoria que faltava, fazer o registro de peso só quando o usuário tocar em "Registrar reciclagem", deixar o login por último e começar a implementar os requisitos, levantando os dados reais e instalando as dependências necessárias.
   Resultado: a IA leu todos os documentos da Unidade I, corrigiu os requisitos e montou o app, testando cada parte no emulador.
2. **Chave do Google Maps.** Explicar onde gerar a chave do Maps e como restringi-la.
   Resultado: passo a passo no Google Cloud Console, com as restrições por aplicativo (pacote e SHA-1) e por API.
3. **Divisão em sprints.** Dividir o trabalho em sprints semanais de 4 semanas.
   Resultado: plano com os requisitos de cada sprint, ordenado pelas dependências entre as partes, e um critério de "pronto" para cada semana.
4. **Revisão do código.** Revisar o código e verificar se está tudo certo antes de enviar ao repositório do grupo.
   Resultado: a revisão achou o erro do mapa ao perder a internet.
5. **Acompanhamento do grupo.** Mostrar o que foi adicionado ao repositório desde o meu último commit e, a partir dos requisitos, o que falta ser feito, dividido em sprints.
   Resultado: resumo dos commits dos colegas e um plano com as sprints 3 a 5 e o que fica fora do escopo.
6. **Sprint 3.** Montar a sprint 3 e fazer todos os testes.
   Resultado: a IA seguiu o protótipo de alta fidelidade e o `justificativas.md`, escreveu os testes e testou no emulador, onde achou o atraso de 1 hora, o ícone vazio e o aviso "Registrado!" que não sumia.

Observação geral: pedir que a IA teste no emulador e mostre a tela trouxe à tona erros que os testes automáticos não pegavam, como o alarme atrasado e o ícone da notificação.

### Como o resultado foi conferido

- `flutter analyze` sem problemas e todos os testes passando (85 no momento deste registro).
- Sprints 1 e 2 testadas no emulador Android (Android 15) e no simulador do iPhone: busca com e sem internet, categorias, mapa com a chave do Maps, localização, filtros e o aviso de sem internet.
- Sprint 3 testada no emulador Android (Android 15): registrar reciclagem e ver o contador subir, criar, editar e apagar lembretes, aceitar a permissão de notificação e esperar a notificação "Hoje tem coleta seletiva" chegar no minuto marcado.
- Confirmação pelo `adb shell dumpsys` de que cada dia do lembrete fica agendado (por exemplo, quinta 12/11 e terça 17/11 às 08:00) e de que editar o lembrete cancela os agendamentos antigos.
- APK de debug e de release compilando.

## Caio

A preencher por Caio.

## Salatiel: sprint 3 (registro de reciclagem, tela Impacto e lembretes)
 
### O que foi feito com apoio da IA
 
- Botão "Registrar reciclagem" no resultado da busca. Ao tocar, o app soma o peso médio do item ao total e mostra o aviso "Registrado! +0,02 kg" (o peso real do item, com vírgula decimal).
- "Ajustar peso" opcional: o aviso tem uma ação que abre um diálogo com campo numérico (aceita vírgula ou ponto) para corrigir o peso daquele registro. Cancelar não altera nada, e valores inválidos ou menores ou iguais a zero são ignorados.
- Uma busca sozinha não registra nada: o registro só acontece ao tocar no botão, como o RF09 foi reescrito no CHANGELOG de 03/11.
- Os registros ficam salvos no aparelho e continuam lá depois de fechar o app.
- Testes automáticos do model e do registro (`test/reciclagem_model_test.dart`).
O código foi estruturado pelo agente do Antigravity a partir de prompts montados com ajuda do Claude. O Claude também ajudou a revisar o que o agente mexeu, a organizar o CHANGELOG.
 
### Como o código está organizado
 
| Arquivo | Função |
|---|---|
| `lib/models/registro_reciclagem.dart` | Um registro de reciclagem: id, item, peso em kg e data, com conversão para JSON. |
| `lib/data/reciclagem_repository.dart` | Lê e grava a lista de registros no aparelho (`shared_preferences`), em uma única chave. |
| `lib/state/reciclagem_model.dart` | Guarda a lista e oferece `carregar()`, `registrar()`, `ajustarPeso()` e `totalKg`. |
| `lib/screens/buscar_screen.dart` | Botão "Registrar reciclagem" no resultado, aviso com "Ajustar peso" e o diálogo de ajuste. |
| `lib/main.dart` | Cria o model junto com os outros e o disponibiliza para o app. |
| `test/reciclagem_model_test.dart` | Testes do registro, do ajuste de peso, da persistência e do diálogo. |
 
Quatro decisões de projeto:
 
- **Registro só por ação do usuário:** buscar um item não soma nada. O total só muda ao tocar em "Registrar reciclagem".
- **Dados só no aparelho (RNF06):** os registros ficam salvos localmente, sem conta e sem dados pessoais. O usuário que não faz login também registra.
- **Peso vem do guia:** o peso médio de cada item é o campo `pesoKg` que já existia no `guia.json`. A IA não inventou nenhum peso.
- **Registro antes do contador:** o RF09 foi entregue primeiro, e o total do mês será lido pela aba Impacto (RF03), da mesma sprint. Por isso o total não foi colocado na tela de conta.
Nenhuma biblioteca nova foi instalada: o `shared_preferences` e o `provider` já estavam no projeto.
 
### Erros gerados pela IA e como foram resolvidos
 
| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| Total exibido na tela de conta | O agente mostrou o total de "kg reciclados" no `conta_screen.dart`, que é a tela de conta do Hapolo e fora do escopo do RF09. | O `git diff` mostrou a mudança antes do commit. O arquivo foi desfeito com `git restore`. |
| Teste quebrou depois disso | O agente tinha escrito um teste que procurava o total na tela de conta, e ele falhou quando a tela voltou ao original. | O teste e o import do `conta_screen.dart` foram removidos do arquivo de teste. |
| Getter desnecessário no `ItemGuia` | O agente adicionou `pesoMedioKg` em `item_guia.dart`, repetindo o `pesoKg` que já existia, e ninguém usava. | `git grep --untracked` confirmou que não era usado e o arquivo foi restaurado. |
| Busca incompleta pelo getter | A primeira checagem com `git grep` não olhava os arquivos novos ainda não rastreados e parecia mostrar que não havia uso. | Foi repetida com `--untracked`, que mostrou que as outras ocorrências eram só o nome de um parâmetro. |
| Linha do CHANGELOG no lugar errado | O agente criou uma seção "Não lançado" e a linha também entrou na seção `[03/11/2026]`. A primeira orientação também mandava criar a seção no topo, mas o arquivo está em ordem crescente de data. | As duas foram removidas e a linha ficou em uma seção `[10/11/2026]` no final do arquivo. |
| Agente parou com erro | O agente do Antigravity terminou a execução com "Agent execution terminated due to error" na primeira tentativa. | A tarefa foi enviada de novo ao agente, que concluiu o código. |
 
### Dados usados
 
- **Pesos dos itens:** vêm do campo `pesoKg` de cada item do guia de classificação (`assets/data/guia.json`), escrito pelo Rafael. O registro usa esse valor como peso inicial.
- **Textos do botão e do aviso:** "Registrar reciclagem", "Registrado! +0,02 kg" e "Ajustar peso" seguem o RF09 do `Docs/requisitos.md`.
### Prompts que funcionaram melhor
 
1. **RF09 inteiro.** Contexto do projeto (pastas, `provider`, regras de dados locais e de fluxo curto), o comportamento esperado em 5 pontos e os passos numerados. Pedi que o agente lesse antes `item_guia.dart`, `buscar_screen.dart`, `main.dart`, `app.dart` e um model da pasta `state/`, para seguir o padrão que já existia, e que não fizesse commit.
   Resultado: o agente reaproveitou o `pesoKg` que já existia, seguiu o padrão do `provider` e não mexeu no login nem no mapa. O erro dele foi mexer no `conta_screen.dart`, que foi pego na revisão.
Observação geral: ler o `git diff` e o `git status` antes de cada commit achou o que os testes automáticos não pegavam, como a mudança no `conta_screen.dart` e o getter que ninguém usava.
 
### Como o resultado foi conferido
 
- `flutter analyze` sem problemas e todos os testes passando.
- RF09 testado no Chrome (`flutter run -d chrome`): busca por "Pilha", botão "Registrar reciclagem" no resultado, aviso "Registrado! +0,02 kg" e diálogo "Ajustar peso" abrindo com o peso atual.
- `git status` e `git diff` conferidos antes do commit, para só entrarem arquivos da sprint e nenhuma linha antiga do CHANGELOG ser alterada.
- O erro `Cannot read properties of undefined (reading 'maps')` do console no Chrome vem da tela do mapa na versão web e não tem relação com a sprint.

## David: sprint 4 (guia de compostagem e dica rotativa)

### O que foi feito com apoio da IA

- Guia de compostagem doméstica (RF06): o que pode ir (restos úmidos e material seco), o que não pode ir e por quê, passo a passo com 3 baldes, uso do chorume, problemas comuns (mau cheiro, mosquinhas, formigas) e o que fazer sem espaço para composteira.
- Três caminhos até o guia, sem criar uma quinta tela (RNF10): o botão "Aprenda a compostar em casa" no card Orgânico da tela Categorias, o botão "Como compostar" no resultado de um item orgânico e o cartão das dicas de compostagem.
- Dica rotativa no rodapé da tela Buscar, como no protótipo de alta fidelidade: a faixa "Dica: compostagem" abre um cartão com o Brotinho e o botão "Entendi". São 8 dicas, que mudam a cada busca e a cada abertura do app. Algumas levam ao guia de compostagem e outras procuram o item no guia (pilha, óleo, isopor...).
- Correção do card de categoria, que estourava a tela com a fonte grande do sistema.
- Testes automáticos do guia de compostagem e das dicas (`test/compostagem_test.dart`).

### Como o código está organizado

| Arquivo | Função |
|---|---|
| `assets/data/compostagem.json` | Conteúdo do guia de compostagem, editado pela equipe. O usuário só consulta (tabela CRUD). |
| `assets/data/dicas.json` | As 8 dicas do rodapé. Cada uma pode levar ao guia de compostagem ou à busca de um item. |
| `lib/screens/compostagem_screen.dart` | Tela do guia de compostagem. Abre por cima da aba atual, sem virar uma quinta tela (RNF10). |
| `lib/state/dicas_model.dart` | Escolhe a dica: muda a cada busca e a cada abertura, e guarda no aparelho só o número da última. |
| `lib/widgets/dica_rodape.dart` | Faixa "Dica: ..." do rodapé e o cartão com o Brotinho e o botão "Entendi". |
| `lib/models/guia_compostagem.dart` e `lib/models/dica.dart` | Leem o JSON do guia e das dicas. |
| `lib/data/conteudo_repository.dart` | Carrega o guia de compostagem e as dicas, que vão junto com o app. |

Três decisões de projeto:

- **Sem aba nova (RNF10):** o guia de compostagem abre por cima da aba atual, com seta de voltar, igual à tela de conta. A explicação ficou em `Docs/justificativas.md`, seção 4.
- **Offline e sem coleta de dados (RNF03 e RNF06):** o guia e as dicas vêm dentro do app. Do aparelho, só fica salvo o número da última dica vista, para a próxima abertura mostrar a seguinte.
- **Dica sem temporizador:** ela muda a cada busca e a cada abertura, como pede o `justificativas.md`, para não distrair nem gastar bateria.

Nenhuma biblioteca nova foi instalada: a sprint usa o `provider` e o `shared_preferences`, que já estavam no projeto.

### Erros gerados pela IA e como foram resolvidos

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| Card de categoria estourava a tela com fonte larga | O teste novo da sprint 4 mostrou que a linha "Orgânico · Lixeira Marrom" passava 15 pixels da borda. O mesmo acontece no celular com a fonte grande do sistema. | A linha virou um `Wrap`: quando não cabe, a lixeira desce para a linha de baixo. |
| Teste tocava num botão fora da tela | A lista monta os cards um pouco antes de eles aparecerem. O teste achava o botão "Aprenda a compostar em casa", mas o toque caía fora da tela. | `ensureVisible` antes do toque, para rolar até o botão aparecer de verdade. |
| Fim do guia de compostagem ficava embaixo da barra de gestos | A margem da lista era fixa e não somava a barra de gestos do Android. Foi visto rolando a tela no emulador. | A margem de baixo soma a área do sistema (`MediaQuery.paddingOf`). |

### Conteúdo do guia
- **Guia de compostagem:** escrito para o projeto com base no manual de compostagem doméstica do Ministério do Meio Ambiente (2017) e nas orientações da Embrapa. As regras batem com as instruções dos itens orgânicos do guia (por exemplo, carne e comida cozida não vão para a composteira), e um teste confere isso.
- **Dicas:** cada dica repete a instrução do item no guia de classificação. Um teste confere se o item citado em cada dica existe no guia.

### Prompts que funcionaram melhor

1. **Sprint 4.** Montar a sprint 4 inteira, fazer os testes e seguir os mesmos padrões dos documentos e dos relatórios do projeto em .md.
   Resultado: a IA conferiu o protótipo de alta fidelidade (cartão "Dica: compostagem") e o `justificativas.md` (dica que muda a cada busca, sem temporizador) antes de escrever, colocou a compostagem dentro do Orgânico para não criar uma quinta tela e testou no emulador, com e sem internet.

Observação geral: testar no emulador achou um erro que os testes automáticos não pegavam, a lista do guia embaixo da barra de gestos.

### Como o resultado foi conferido

- `flutter analyze` sem problemas e todos os testes passando (100 no momento deste registro).
- Sprint 4 testada no emulador Android (Android 15): faixa "Dica: compostagem" na primeira abertura e outra dica ao reabrir o app e a cada busca, cartão com "Entendi", "Como compostar em casa" e "Ver como descartar", botão no card Orgânico e no resultado de "Casca de banana" e "Borra de café", e o guia inteiro aberto com o Wi-Fi e os dados desligados.
- APK de debug e de release compilando.
