# Registro de uso de IA

Este documento registra como a inteligência artificial generativa foi usada no projeto, conforme o item b-vi do Projeto da Unidade II. Cada integrante preenche a própria seção com o que fez, os prompts que funcionaram melhor, os erros que a IA gerou e como foram resolvidos.

A IA foi usada como ferramenta de apoio. O código gerado foi lido, testado no celular e só entrou no repositório depois de funcionar.

## Resumo por integrante

| Integrante | Parte do projeto | Ferramenta de IA |
|---|---|---|
| Hapolo | Login opcional com Firebase, tela de conta, ícone do app, Firestore (sincronização) e busca por foto | Claude Code |
| Rafael | Sprints 1, 2 e 3 (busca, categorias, mapa, contador de impacto e lembretes) e polimento da sprint 6 (acessibilidade e iOS) | Claude Code |
| Caio | Diagramas de casos de uso e classes | Claude Code |
| Salatiel | Sprint 3 (registro de reciclagem, tela Impacto e lembretes de coleta) e sprint 6 (mascotes, versão web e modelagem do banco) | Agente do Antigravity, Claude e Claude Code |
| David | Sprint 4 (guia de compostagem e dica rotativa da tela Buscar) | Claude Code |

## Hapolo: login opcional, conta, ícone, Firestore e busca por foto

### O que foi feito com apoio da IA

- Telas de entrar, criar conta e recuperar senha, fiéis ao protótipo de alta fidelidade, com o botão "Não quero fazer login".
- Login com e-mail e senha e com Google pelo Firebase Authentication, e tela de conta (editar nome, sair e excluir).
- Ícone do app com o Brotinho.
- Firestore para quem tem conta: registros de reciclagem e lembretes são sincronizados com a conta. Quem usa o app sem login fica só com os dados do aparelho.
- Busca por foto (RF08), com reconhecimento no aparelho pelo ML Kit.
- Testes automáticos de cada uma dessas partes.

### Como o código está organizado

| Arquivo | Função |
|---|---|
| `lib/services/auth_repositorio.dart` e `auth_firebase.dart` | Contrato do login e a implementação com o Firebase Authentication, com as mensagens de erro em português. |
| `lib/state/auth_model.dart` | Guarda a sessão (precisa escolher, visitante ou logado) e lembra do "Não quero fazer login". |
| `lib/screens/login_screen.dart` e `conta_screen.dart` | As telas de login e de conta. |
| `lib/services/nuvem_repositorio.dart` | Contrato e implementação do Firestore, com a conversão entre as classes Dart e os documentos. |
| `lib/state/sincronizacao_model.dart` | Decide quando sincronizar (ao entrar na conta e quando a internet volta). |
| `firestore.rules` | Regras de segurança: cada usuário só acessa `usuarios/{seu uid}`. |
| `lib/services/reconhecimento_imagem.dart`, `lib/data/rotulos_repository.dart` e `assets/data/rotulos.json` | Câmera, reconhecimento da foto e a tabela que liga o que o ML Kit vê aos itens do guia. |
| `lib/widgets/busca_por_foto.dart` | O fluxo da foto: escolher câmera ou galeria, analisar e confirmar a sugestão. |

Decisões de projeto:

- O app só conversa com contratos (`AuthRepositorio`, `NuvemRepositorio`). Por isso os testes usam versões falsas e rodam sem internet e sem Firebase.
- O login é opcional (RNF06). Sem o `google-services.json`, o app abre normalmente e "Não quero fazer login" continua funcionando.
- O aparelho é a fonte principal dos dados e o Firestore é uma cópia para quem tem conta. Assim o app funciona offline e quem não faz login não envia nada para a nuvem (RNF06 e RNF07).

Estrutura no Firestore:

| Caminho | Campos |
|---|---|
| `usuarios/{uid}/registros/{id}` | `item` (texto), `pesoKg` (número), `data` (data e hora) |
| `usuarios/{uid}/lembretes/{id}` | `hora` e `minuto` (números), `titulo` (texto), `dias` (lista de 1 a 7) |

Como a sincronização funciona: o que só existe de um lado vai para o outro; se o mesmo registro tiver valores diferentes, vale o do aparelho; sem internet, o Firestore guarda a gravação e envia depois; ao excluir a conta, os dados da nuvem são apagados antes.

### Bibliotecas escolhidas

| Biblioteca | Por que foi escolhida |
|---|---|
| `firebase_core` e `firebase_auth` | O enunciado exige Firebase para autenticação. O `firebase_auth` já traz e-mail e senha, recuperação de senha, exclusão de conta e login com Google, sem outro pacote. |
| `cloud_firestore` | O enunciado exige Firebase também para o banco de dados. Ele guarda uma cópia no aparelho e envia as gravações quando a internet volta, o que combina com o app offline. |
| `shared_preferences` | Guardar no aparelho uma informação simples (se o usuário escolheu seguir sem login). |
| `image_picker` | Abre a câmera ou a galeria, sem permissão própria no Android. |
| `google_mlkit_image_labeling` | Reconhece a foto no próprio aparelho, sem internet, e a foto não sai do celular (RNF06). |

### Erros gerados pela IA e como foram resolvidos

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| App em tela preta ao abrir | O `shared_preferences` 2.5.x usa uma biblioteca nativa (`libdartjni.so`) que não entrava no APK, e o app falhava antes de abrir a primeira tela. Apareceu no log do celular. | `shared_preferences_android` fixado na versão 2.4.28, com comentário no `pubspec.yaml`. |
| Login do Google não funcionava | O `google-services.json` foi baixado antes de registrar o SHA-1 e de ativar o Google, então não tinha cliente OAuth. | SHA-1 registrado, Google ativado e arquivo baixado de novo. |
| Nome não aparecia no perfil | O app lia o usuário antes de o nome salvo voltar do servidor. | `reload()` depois de salvar o nome; sem nome, o perfil mostra o começo do e-mail. |
| Telas de login diferentes do protótipo | A primeira versão usava o visual padrão do Flutter, com rótulos, títulos e botões que o protótipo não tem. | As telas foram refeitas comparando com o protótipo. Ficou só o que melhora contraste e acessibilidade, como o botão em verde escuro. |

### Decisões que o grupo revisou

- **`google-services.json` no repositório:** a IA sugeriu commitá-lo para o app funcionar na correção. Ele traz uma chave de API do Firebase, que não é uma senha e vai dentro de qualquer APK. Foi mantido, e no Google Cloud Console foi conferido que a chave já vem restrita às APIs do Firebase.
- **Regras do Firestore:** foram escritas com a IA e precisam ser testadas no simulador de regras do console antes da entrega.

### Prompts que funcionaram melhor

Resumo dos pedidos que levaram a um resultado direto, na ordem em que foram feitos.

1. **Login opcional.** Implementar a autenticação opcional com Firebase Authentication, seguindo o protótipo e os requisitos, com a opção de usar o app sem login.
2. **Diagnóstico da tela preta.** Analisar o log do `flutter run` e o do aparelho para achar por que o app ficava numa tela preta.
3. **Login com Google.** Verificar a configuração do Firebase e do projeto Android, porque o login com Google não funcionava.
4. **Ícone.** Criar o ícone do aplicativo a partir do mascote Brotinho, no formato adaptativo do Android.
5. **Firestore.** Gravar os registros e os lembretes de quem tem conta no Firestore, mantendo o aparelho como fonte principal e sem enviar nada de quem usa o app sem login.
6. **Busca por foto.** Implementar a busca por foto com reconhecimento no aparelho, em que o usuário confirma a sugestão.
7. **Telas fiéis ao protótipo.** Refazer as telas de login para ficar iguais ao protótipo de alta fidelidade.

Descrever o sintoma que aparece na tela e fornecer o log do aparelho deu resultados melhores do que pedir uma correção sem contexto.

### Como o resultado foi conferido

- `flutter analyze` sem problemas e todos os testes passando (138 no momento deste registro).
- Teste no celular real: criar conta, entrar, sair, editar nome, senha errada, recuperar senha, excluir conta, "Não quero fazer login" e login com Google.
- A conferir no celular: a sincronização com o Firestore real e o reconhecimento de fotos de resíduos de verdade, que dependem de criar o banco e de ajustar a tabela `rotulos.json` com fotos reais.

## Rafael: sprints 1, 2 e 3 (busca, categorias, mapa e tela Impacto) e sprint 6

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
- **Pesos médios dos 81 itens:** estimativas feitas para o projeto, conferidas pelo grupo em 24/11/2026 e mantidas.
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

### Sprint 6: acessibilidade e iOS (24/11/2026)

**O que foi feito com apoio da IA:** permissões de câmera e galeria no iOS, iOS mínimo 15.5 para o ML Kit e um teste de acessibilidade que monta o app inteiro e confere cada tela com as regras do próprio Flutter: `androidTapTargetGuideline` e `iOSTapTargetGuideline` (48 dp), `labeledTapTargetGuideline` (todo botão com nome para o leitor de tela) e `textContrastGuideline` (4,5:1), além da fonte do sistema em 200%.

**O que o teste encontrou e foi corrigido:**

- Filtros do Mapa com 36 dp de altura, presos numa faixa de altura fixa.
- Verde escuro sobre verde claro com 4,35:1 no filtro selecionado e no botão "Ativar".
- Tela Buscar estourando 13 px de altura com a fonte grande; o mesmo aconteceria com o teclado aberto em celular pequeno. O cabeçalho, o campo e o resultado passaram a rolar juntos.
- Textos estourando a largura com a fonte grande (lixeira, nome da categoria e "Novo lembrete").

**Erro que só apareceu no emulador:** com a fonte em 200%, os nomes das abas quebravam no meio da palavra ("Impact-o"). Como o texto quebra sem estourar, o teste não acusava nada; foi preciso acrescentar uma verificação específica, que falha sem a correção e passa com ela.

**Erro da IA:** ao formatar o código com o `dart format`, a IA reformatou 34 arquivos, inclusive código dos colegas que ela não tinha alterado. A formatação foi desfeita nesses arquivos para o histórico mostrar só as mudanças reais.

**O que ficou para o grupo:** os horários das cooperativas e os endereços sem número só se confirmam ligando ou indo ao local, então a IA não mexeu nesses dados. O grupo conferiu e decidiu manter como estão. O build de iOS não foi compilado pela IA porque o Mac usado não tem Xcode; o Rafael testou o app no iOS e ele está rodando. A entrega vai sem o `GoogleService-Info.plist`, então no iOS o app funciona como visitante, sem login e sem sincronização.

**Como foi conferido:** `flutter analyze` sem problemas, 152 testes passando e o app rodando no emulador Android 15, com fonte normal e em 200%: busca com erro de digitação, Mapa e Impacto. O Rafael testou no iOS e o grupo testou no celular Android; o app roda nos dois.

## Caio: diagramas da Unidade II (casos de uso e classes)

### O que foi feito com apoio da IA

- Diagrama de casos de uso, em três diagramas, um por módulo: guia e mapa, impacto e lembretes, conta e sincronização.
- Diagrama de classes, em três páginas: modelos de domínio, repositórios e serviços, e sincronização com o Firestore.

Esta parte foi feita por mim. Usei o Claude como apoio: ele gerou os primeiros rascunhos dos diagramas e das tabelas a partir do que eu passei, e eu refiz e ajustei tudo, mantendo só o que estava certo. Fui eu que defini o que entra em cada diagrama e o que fica de fora, levei as dúvidas para o grupo e trouxe as respostas, conferi os diagramas com o código da branch `unidade-2` e com o `requisitos.md`, e pedi e apliquei as correções em várias rodadas.

### Como usei a IA

- Para gerar os primeiros rascunhos dos diagramas.
- Para montar a lista de dúvidas que levei ao grupo.
- Para comparar os diagramas com o código quando o grupo fazia commits novos, apontando o que mudava.

### Como o resultado está organizado

| Arquivo | Função |
|---|---|
| `Docs/diagrama-casos-de-uso.pdf` | Os três diagramas de casos de uso (UC01 a UC17, com os auxiliares UC01a, UC04a e UC05a). |
| `Docs/diagrama-de-classes.pdf` | Os três diagramas de classes, feitos a partir dos arquivos de `lib/`. |

### Ferramenta dos rascunhos

| Ferramenta | Por que |
|---|---|
| PlantUML | Os rascunhos foram gerados nessa ferramenta, que cria o diagrama a partir de um texto. Como os diagramas mudaram várias vezes (revisões do colega, commits novos do grupo), foi mais rápido alterar e gerar de novo do que começar do zero. Tem a notação UML que precisei (include, extend, generalização de atores, interfaces e enumerações). |

### Erros gerados pela IA e como foram resolvidos

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| Diagrama ilegível | O primeiro rascunho tinha todos os casos de uso num diagrama só, com linhas cruzadas. | Dividi em três diagramas por módulo. |
| Funções que não estavam nos requisitos | A IA incluiu histórico de consultas, favoritos e estatística semanal, que aparecem no aditivo, mas não nos requisitos nem no protótipo. | A revisão de um colega apontou. Tirei os três. |
| Casos de uso repetidos | "Ver contador de impacto" e "Ver quilos reciclados no mês" eram dois casos, mas a tela Impacto mostra o total e o do mês no mesmo cartão. | Juntei os dois no UC10, "Ver impacto da reciclagem (total e do mês)". |
| Detalhe técnico no diagrama | "Enviar lote com IDs únicos" apareceu como caso de uso, mas é detalhe de implementação. | Removi. A regra continua nos requisitos. |
| Atores confusos | O ator "Visitante" aparecia em funções que valem para todos, e o usuário logado "herdava" Criar conta. | Criei o ator Usuário, com Visitante e Usuário autenticado como especializações. |
| Ator "Sistema" | A IA criou o ator "Sistema (automático)" para a notificação e a sincronização, mas o sistema não pode ser ator dele mesmo. | A notificação (UC12) passou a ter como ator externo o serviço de notificações do celular, e a sincronização (UC17) ficou com o usuário autenticado e o Firebase. |
| Casos que não eram casos de uso | O aviso de falta de conexão aparecia como caso de uso, e "abrir rota" e "ligar" estavam juntos num só. | O aviso virou fluxo alternativo do UC04. Separei em UC05 (abrir rota) e UC05a (ligar). |
| Ligação a mais | O UC08 (registrar reciclagem) estava ligado direto ao usuário e também estendia a busca. No código, o registro só é feito a partir do resultado da busca (`buscar_screen.dart`). | Tirei a ligação direta. |
| Campos inventados | O primeiro rascunho do diagrama de classes tinha campos que não existem no código (`ativo` no `Lembrete`; `categoriaId`, `sincronizado` e `usuarioUid` no `RegistroReciclagem`). | Refiz lendo o código da branch `unidade-2`. |

### Prompts que funcionaram melhor

1. **Casos de uso a partir do enunciado.** Começar pelo diagrama de casos de uso com base no PDF do projeto, no documento da Unidade II e nos requisitos do grupo.
2. **Ler o código antes.** Mandar o zip da branch `unidade-2` e pedir que o diagrama de classes use o repositório como referência, em vez de descrever as classes de memória.
3. **Dúvidas para o grupo.** Pedir uma lista curta de perguntas para levar ao grupo, como por exemplo, quem sincroniza com o Firebase.
4. **Atualizar depois de cada commit.** Mandar o zip novo e pedir para comparar com a versão anterior e dizer o que muda nos diagramas.

Mandar o código real deu resultado melhor do que descrever as classes. Foi a causa dos campos inventados no primeiro rascunho.

### Como o resultado foi conferido

- Conferi os casos de uso com os requisitos funcionais do `requisitos.md` e com as regras do documento.
- Comparei os diagramas de classes com `lib/` da branch `unidade-2` depois de cada commit do grupo.

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

### Sprint 6: mascotes, versão web e modelagem do banco (24/11/2026)

**O que foi feito com apoio da IA (Claude Code):**

- Mascotes ilustrados nos cards da tela Categorias. As imagens e o widget `MascoteCategoria` vieram num pacote com instruções (`COMO_USAR.md`). A IA copiou os arquivos para o projeto, registrou `assets/mascotes/` no `pubspec.yaml` e pôs o mascote à direita da lista de exemplos, num `Row` alinhado embaixo, com a lista dentro de um `Expanded`.
- Versão web (`web/`) para testar o app no navegador, com o script do Google Maps no `web/index.html`. Era isso que causava o erro `reading 'maps'` anotado na sprint 3: sem o script, a tela do mapa quebrava no Chrome.
- Modelagem do banco de dados (itens b-iii e b-iv) em `Docs/modelagem-banco.md`. O documento foi entregue em PDF e convertido para Markdown, com os diagramas em Mermaid, e cada tabela foi conferida com o código (`nuvem_repositorio.dart`, os models e o `sincronizacao_model.dart`).
- Plano das sprints e CHANGELOG atualizados, sem alterar o que os colegas escreveram.

| Arquivo | Função |
|---|---|
| `lib/widgets/mascote_categoria.dart` | Mostra o mascote da categoria pelo nome, com ou sem acento, e não quebra o card se a imagem faltar. |
| `assets/mascotes/` | Uma imagem por categoria (plástico, papel, vidro, metal, orgânico e perigoso), que vai dentro do app e funciona offline (RNF03). |
| `lib/screens/categorias_screen.dart` | Card da categoria com a lista de exemplos e o mascote lado a lado. |
| `web/` | Versão para navegador, com nome, descrição e cores do LixoZero e o script do Google Maps. |
| `Docs/modelagem-banco.md` | Coleções e documentos do Firestore, mapeamento das classes Dart, operações do `NuvemRepositorio`, sincronização e regras de segurança. |

**Erros e problemas, e como foram resolvidos:**

| Erro | O que aconteceu | Como foi resolvido |
|---|---|---|
| Aviso no código do pacote | O widget do pacote usava `(_, __, ___)` no `errorBuilder`, e o `flutter analyze` acusou `unnecessary_underscores`. | Trocado por `(_, _, _)`, o mesmo estilo do resto do projeto. |
| Pacote extraído fora do projeto | O zip foi extraído ao lado da pasta do projeto, e não dentro dela. | A IA procurou os arquivos, leu o conteúdo antes de copiar e copiou para os lugares certos. |
| Colega mudou o código durante o trabalho | O Rafael subiu commits que mexiam na mesma tela e no CHANGELOG. | O trabalho foi guardado num `git stash`, o `git pull` foi feito e a implementação foi refeita por cima do código novo, mantendo a correção dele na tela. |
| Modelagem diferente do código | A seção de regras de segurança do PDF mostrava uma regra genérica, mas o `firestore.rules` real separa registros e lembretes, valida campos e tipos e nega todo o resto. | A seção passou a mostrar as regras reais, com um resumo do que cada uma garante. |
| Mensagem de commit malformada | O primeiro commit dos mascotes ficou sem a linha em branco depois do título, e o GitHub mostrava a mensagem inteira como título. | A mensagem foi corrigida antes de qualquer colega usar o commit. |
| Arquivos alterados pelo `flutter create` | Ao gerar a pasta `web/`, o Flutter também mudou o `.metadata` e o `analysis_options.yaml` e criou um `test/widget_test.dart`. | O `git status` mostrou as mudanças, que foram desfeitas; só a `web/` entrou no commit. |
| `pubspec.lock` com versões novas | O Flutter mais novo deste computador atualizava Firebase, Firestore e ML Kit no `pubspec.lock`. | O arquivo ficou fora dos commits, para não trocar as versões que o grupo testou no Android e no iOS. |
| Conflito no CHANGELOG | No merge da `unidade-2` na `main`, as linhas dos mascotes e da modelagem caíram no mesmo ponto. | As duas linhas foram mantidas, e os testes rodaram de novo antes do push. |
| Testes travando no computador | O `flutter test` falhava antes de rodar por causa do "ó" de `Repositórios` no caminho, que o compilador de shaders do Flutter não aceita. | Os testes e o app rodaram a partir de uma unidade temporária sem acento (`subst X:`). |

**Prompts que funcionaram melhor:**

1. **Passo a passo do pacote dos mascotes.** Onde ficam os arquivos, o que registrar no `pubspec.yaml`, como encaixar o widget no card (`Row` alinhado embaixo e lista no `Expanded`), a entrada do CHANGELOG seguindo o `COMO_USAR.md` e rodar `flutter analyze` e `flutter test` no final.
2. **"Dê um git pull e refaça a implementação."** Pedir o pull antes de commitar evitou sobrescrever o que o colega tinha feito na mesma tela.
3. **Conferir a modelagem com o código antes de subir.** Foi o que achou a diferença nas regras de segurança.
4. **Atualizar as sprints sem tirar ninguém.** Acrescentar o nome junto do colega na sprint que já existia, em vez de criar outra.

**Como foi conferido:** `flutter analyze` sem avisos novos e 152 testes passando, inclusive os de acessibilidade com fonte em 200% na tela Categorias. O app foi aberto no Chrome e os mascotes, a tela Categorias e o mapa foram conferidos. O `git diff` e o `git status` foram lidos antes de cada commit.

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
