# Changelog

Todas as mudanças relevantes do protótipo LixoZero são registradas aqui.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [01/09/2026]

### Adicionado

- Estudo de caso — 2.1 Problema, 2.2 Público e usuários, 2.7 Restrições e condições —
  Hapolo. (`Docs/estudo-de-caso.md`)
- Estudo de caso — 2.4 Objetivo e proposta de valor, 2.8 Pontos de atenção — Caio.
  (`Docs/estudo-de-caso.md`)
- Estudo de caso — 2.3 Contexto de uso, 2.5 Personalidade, identidade e experiência —
  Salatiel. (`Docs/estudo-de-caso.md`)
- Estudo de caso — 2.6 Funcionalidades e características já definidas — David.
  (`Docs/estudo-de-caso.md`)

## [08/09/2026]

### Adicionado

- Pesquisa — Hapolo e David. (`Docs/pesquisa.md`)
- Benchmark — Salatiel. (`Docs/benchmark.md`)
- Personas — Caio. (`Docs/personas.md`)
- Apresentação — Caio, Hapolo e Salatiel. (`Docs/apresentação.pdf`)

## [15/09/2026]

### Adicionado

- 2.1 Funcionalidades — Hapolo. (`Docs/requisitos.md`)
- 2.2 Requisitos Funcionais — Salatiel. (`Docs/requisitos.md`)
- 2.3 Requisitos Não-Funcionais — Rafael. (`Docs/requisitos.md`)
- 2.4 CRUD — Caio. (`Docs/requisitos.md`)
- 2.5 Priorizações — David. (`Docs/requisitos.md`)
- Apresentação — Caio, David, Hapolo, Rafael e Salatiel. (`Docs/apresentacaoRequisitos.pdf`)

## [01/10/2026]

### Adicionado

- 1 Escolha das cores (paleta e contraste) — Hapolo. (`Docs/justificativas.md`)
- 2 Tipografia — Hapolo. (`Docs/justificativas.md`)
- 3 Organização das informações — Hapolo. (`Docs/justificativas.md`)
- 4 Navegação — Hapolo. (`Docs/justificativas.md`)
- 5 Componentes — Hapolo. (`Docs/justificativas.md`)
- 6 Acessibilidade — Hapolo. (`Docs/justificativas.md`)
- 7 Decisões relacionadas ao contexto de uso — Hapolo. (`Docs/justificativas.md`)
- 8 Arquitetura do sistema — Hapolo. (`Docs/justificativas.md`)

## [05/10/2026]

### Adicionado

- Protótipo de baixa fidelidade — David, Hapolo e Salatiel. (`Docs/prototipoBaixaFidelidade.pdf`)
- Protótipo de alta fidelidade — Caio, Hapolo e Salatiel. (`Docs/prototipoAltaFidelidade.pdf`)
- Apresentação final da Unidade I — Caio e Hapolo. (`Docs/apresentacaoFinalUnidadeI.pdf`)

## [03/11/2026]

### Adicionado

- Projeto Flutter, tema com a paleta e fontes Montserrat e Inter — Rafael. (`pubspec.yaml`, `lib/theme/app_theme.dart`, `assets/fonts/`)
- Navegação com as 4 abas e mascote Brotinho — Rafael. (`lib/app.dart`, `lib/widgets/`, `assets/images/`)
- Guia de classificação com 6 categorias e 81 itens — Rafael. (`assets/data/guia.json`, `lib/models/`)
- Busca offline que aceita plural, falta de acento e erro de digitação — Rafael. (`lib/data/busca.dart`, `test/busca_test.dart`)
- Tela "Onde jogo isso?" com resultado, dúvidas comuns e "não encontrei" — Rafael. (`lib/screens/buscar_screen.dart`)
- Tela de categorias com código de cores; tocar num exemplo abre a busca — Rafael. (`lib/screens/categorias_screen.dart`)
- Lista com os 9 ecopontos da Emsurb e as cooperativas CARE, Coores e União — Rafael. (`assets/data/pontos.json`, `lib/data/pontos_repository.dart`, `test/pontos_test.dart`)
- Mapa com Google Maps e chave fora do Git — Rafael. (`lib/screens/mapa_screen.dart`, `android/`, `ios/`)
- Localização, distância, filtros, "Como chegar" e "Ligar" — Rafael. (`lib/services/localizacao_service.dart`, `lib/screens/mapa_screen.dart`)
- Aviso de sem internet e botão "Ver pontos de coleta" no resultado da busca — Rafael. (`lib/state/conexao_model.dart`, `lib/screens/buscar_screen.dart`)
- Telas de entrar, criar conta e recuperar senha, com o botão "Não quero fazer login" — Hapolo. (`lib/screens/login_screen.dart`, `lib/state/auth_model.dart`)
- Login com e-mail e senha e com Google pelo Firebase Authentication, com erros em português — Hapolo. (`lib/services/auth_firebase.dart`, `lib/services/auth_repositorio.dart`, `android/app/google-services.json`)
- Tela de conta: editar nome, sair e excluir a conta — Hapolo. (`lib/screens/conta_screen.dart`)
- Validação dos campos do login — Hapolo. (`lib/data/validadores.dart`)
- Testes do login — Hapolo. (`test/login_test.dart`)
- Ícone do app com o Brotinho — Hapolo. (`android/app/src/main/res/`)
- Registro de uso de IA, com a seção do login preenchida e espaços para os demais — Hapolo. (`Docs/uso-de-ia.md`)
- Diagrama de Casos de uso - Caio. (`Docs/diagrama-casos-de-uso.pdf`)

### Alterado

- Categoria Metal incluída na funcionalidade 7, no RF07 e no README — Rafael. (`Docs/requisitos.md`, `README.md`)
- RF09 reescrito: o registro de reciclagem só acontece ao tocar em "Registrar reciclagem" — Rafael. (`Docs/requisitos.md`, `Docs/justificativas.md`)
- Tabela CRUD ajustada ao login opcional e ao "ajustar peso" — Rafael. (`Docs/requisitos.md`)
- Priorização: guia offline junto com a busca, login por último, RF11 e RF12 fora do protótipo — Rafael. (`Docs/requisitos.md`)
- Correção de formatação da seção 2.5 — Rafael. (`Docs/estudo-de-caso.md`)
- Correção no mapa: não tenta mover o mapa depois que a internet cai — Rafael. (`lib/screens/mapa_screen.dart`)
- Correção da tela preta ao abrir o app: `shared_preferences_android` fixado na versão 2.4.28 — Hapolo. (`pubspec.yaml`)

## [10/11/2026]

### Adicionado

- Registro de reciclagem: botão "Registrar reciclagem" no resultado da busca, soma do peso médio com aviso "Registrado! +0,03 kg" e ajuste de peso — Salatiel. (`lib/models/registro_reciclagem.dart`, `lib/data/reciclagem_repository.dart`, `lib/state/reciclagem_model.dart`, `lib/screens/buscar_screen.dart`, `test/reciclagem_model_test.dart`)
- Tela Impacto com o contador de quilos reciclados no mês e desde o começo (RF03) — Rafael. (`lib/screens/impacto_screen.dart`, `lib/state/reciclagem_model.dart`)
- Lembretes de coleta seletiva: criar, ver, editar e apagar com confirmação, salvos no aparelho (RF04) — Rafael. (`lib/models/lembrete.dart`, `lib/data/lembretes_repository.dart`, `lib/state/lembretes_model.dart`, `lib/screens/impacto_screen.dart`)
- Notificação semanal no dia e horário de cada lembrete, com aviso se o usuário negar a permissão — Rafael. (`lib/services/notificacoes.dart`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/drawable/ic_notificacao.xml`, `ios/Runner/AppDelegate.swift`)
- Testes do contador, dos lembretes e das notificações — Rafael. (`test/impacto_screen_test.dart`, `test/lembretes_test.dart`, `test/notificacoes_falsas.dart`)
- Seção do Rafael no registro de uso de IA, com as sprints 1, 2 e 3 — Rafael. (`Docs/uso-de-ia.md`)
- Guia de compostagem doméstica (RF06): o que pode e o que não pode ir, passo a passo com baldes, chorume, problemas comuns e o que fazer sem espaço — David. (`assets/data/compostagem.json`, `lib/models/guia_compostagem.dart`, `lib/data/conteudo_repository.dart`, `lib/screens/compostagem_screen.dart`)
- Botão "Aprenda a compostar em casa" no card Orgânico e "Como compostar" no resultado de itens orgânicos — David. (`lib/screens/categorias_screen.dart`, `lib/screens/buscar_screen.dart`)
- Dica rotativa no rodapé da tela Buscar, com 8 dicas que mudam a cada busca e a cada abertura, e o cartão do protótipo com "Entendi" — David. (`assets/data/dicas.json`, `lib/models/dica.dart`, `lib/state/dicas_model.dart`, `lib/widgets/dica_rodape.dart`)
- Testes do guia de compostagem e das dicas — David. (`test/compostagem_test.dart`, `test/dicas_falsas.dart`)
- Seção do David no registro de uso de IA, com a sprint 4 — David. (`Docs/uso-de-ia.md`)
- Plano das sprints da Unidade II, com o que já foi feito e o que falta para finalizar o projeto — Rafael. (`Docs/sprints.md`)
- Registro de uso de IA: seção da Sprint 3 do Salatiel — Salatiel. (`Docs/uso-de-ia.md`)

### Alterado

- A aba Impacto deixou de ser "Em construção" — Rafael. (`lib/app.dart`, `lib/main.dart`)
- Desugaring ligado no Android, exigido pelo `flutter_local_notifications`, que fica na versão 22 porque a 23 pede o Android SDK 37 — Rafael. (`android/app/build.gradle.kts`, `pubspec.yaml`)
- Correção do aviso "Registrado!", que não sumia e cobria as outras abas — Rafael. (`lib/screens/buscar_screen.dart`, `test/reciclagem_model_test.dart`)
- Correção no card de categoria: com fonte grande, a lixeira desce para a linha de baixo em vez de estourar a tela — David. (`lib/screens/categorias_screen.dart`)
- Testes que montam a tela Buscar passam a receber as dicas do rodapé — David. (`test/reciclagem_model_test.dart`, `test/impacto_screen_test.dart`)
- Navegação: onde fica o guia de compostagem sem criar uma quinta tela — David. (`Docs/justificativas.md`)

## [17/11/2026]

### Adicionado

- Firestore para quem tem conta: registros de reciclagem e lembretes são gravados em `usuarios/{uid}`, com cópia no aparelho e envio quando a internet volta; quem escolhe "Não quero fazer login" continua só com os dados do aparelho — Hapolo. (`lib/services/nuvem_repositorio.dart`, `lib/state/reciclagem_model.dart`, `lib/state/lembretes_model.dart`)
- Sincronização ao entrar na conta e quando a conexão volta, com o estado na tela Conta ("Dados sincronizados às 14:32") — Hapolo. (`lib/state/sincronizacao_model.dart`, `lib/screens/conta_screen.dart`)
- Excluir a conta também apaga os registros e lembretes dela na nuvem — Hapolo. (`lib/state/auth_model.dart`)
- Regras de segurança do Firestore: cada usuário só acessa o que é dele — Hapolo. (`firestore.rules`)
- Busca por foto (RF08): botão de câmera na busca, reconhecimento no aparelho com o ML Kit, até 3 sugestões para o usuário confirmar e mensagem quando a foto não é reconhecida — Hapolo. (`lib/services/reconhecimento_imagem.dart`, `lib/data/rotulos_repository.dart`, `lib/widgets/busca_por_foto.dart`, `assets/data/rotulos.json`, `lib/screens/buscar_screen.dart`)
- Testes da sincronização, da conversão para o Firestore, da exclusão da conta e da busca por foto — Hapolo. (`test/sincronizacao_test.dart`, `test/busca_por_foto_test.dart`, `test/nuvem_falsa.dart`)
- Diagrama de classes — Caio. (`Docs/diagrama-de-classes.pdf`)
- Registro de uso de IA, seção do Caio. — Caio. (`Docs/uso-de-ia.md`)

### Alterado

- RF03, RF08, RNF07, tabela CRUD (registros, lembretes e conta) ajustados ao uso do Firestore e à busca por foto — Hapolo. (`Docs/requisitos.md`)
- Telas de login refeitas para ficar fiéis ao protótipo de alta fidelidade — Hapolo. (`lib/screens/login_screen.dart`, `lib/data/validadores.dart`, `assets/images/google_g.png`)
- Diagrama de casos de uso atualizado com a busca por foto, a sincronização e a revisão dos atores — Caio. (`Docs/diagrama-casos-de-uso.pdf`)
- Plano das sprints atualizado: sprint 5 (busca por foto e Firestore) e diagramas concluídos, e novas pendências da sprint 6 (permissões de câmera no iOS, versão mínima do iOS, regras do Firestore e entrega) — Rafael. (`Docs/sprints.md`)

## [24/11/2026]

### Adicionado

- Testes de acessibilidade em todas as telas (Buscar, Mapa, Impacto, Categorias, login, conta e compostagem): área de toque de 48 dp, botões com nome para o leitor de tela, contraste de 4,5:1 e fonte do sistema em 200% sem estourar o layout — Rafael. (`test/acessibilidade_test.dart`)

### Alterado

- iOS: permissões de câmera e galeria para a busca por foto (sem elas o app fechava ao abrir a câmera no iPhone) e versão mínima do iOS de 15.0 para 15.5, exigida pelo ML Kit — Rafael. (`ios/Runner/Info.plist`, `ios/Podfile`, `ios/Runner.xcodeproj/project.pbxproj`)
- Tela Buscar: cabeçalho, campo e resultado rolam juntos, e a dica do rodapé some com o teclado aberto; com a fonte grande ou o teclado aberto, a tela estourava 13 px — Rafael. (`lib/screens/buscar_screen.dart`)
- Filtros do Mapa com área de toque de 48 dp (eram 36) e que crescem com a fonte do sistema — Rafael. (`lib/screens/mapa_screen.dart`)
- Contraste do filtro selecionado do Mapa e do botão "Ativar" da localização: o verde escuro sobre o verde claro dava 4,35:1, agora 5,66:1 — Rafael. (`lib/theme/app_theme.dart`, `lib/screens/mapa_screen.dart`)
- Nomes das abas numa linha só com a fonte grande (antes quebravam em "Impact-o" e "Catego-ria") — Rafael. (`lib/widgets/barra_navegacao.dart`)
- Textos que estouravam a tela com a fonte grande: lixeira no resultado da busca e no card de categoria, nome da categoria e botão "Novo lembrete" — Rafael. (`lib/screens/buscar_screen.dart`, `lib/screens/categorias_screen.dart`, `lib/widgets/comuns.dart`, `lib/screens/impacto_screen.dart`)
- Plano das sprints, README e registro de uso de IA atualizados com a sprint 6 — Rafael. (`Docs/sprints.md`, `README.md`, `Docs/uso-de-ia.md`)
- App testado e rodando no iOS; a entrega vai sem o `GoogleService-Info.plist`, então no iOS o app funciona como visitante, sem login e sem sincronização. Merge da `unidade-2` na `main` registrado no plano — Rafael. (`Docs/sprints.md`, `README.md`, `Docs/uso-de-ia.md`)
- Dados conferidos pelo grupo e mantidos (pesos dos itens, cooperativas e ecopontos); app testado e rodando no celular Android e no iOS. Unidade II concluída — Rafael. (`Docs/sprints.md`, `README.md`, `Docs/uso-de-ia.md`)
