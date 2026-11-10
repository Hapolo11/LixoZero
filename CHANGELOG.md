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

### Alterado

- A aba Impacto deixou de ser "Em construção" — Rafael. (`lib/app.dart`, `lib/main.dart`)
- Desugaring ligado no Android, exigido pelo `flutter_local_notifications`, que fica na versão 22 porque a 23 pede o Android SDK 37 — Rafael. (`android/app/build.gradle.kts`, `pubspec.yaml`)
- Correção do aviso "Registrado!", que não sumia e cobria as outras abas — Rafael. (`lib/screens/buscar_screen.dart`, `test/reciclagem_model_test.dart`)
- Correção no card de categoria: com fonte grande, a lixeira desce para a linha de baixo em vez de estourar a tela — David. (`lib/screens/categorias_screen.dart`)
- Testes que montam a tela Buscar passam a receber as dicas do rodapé — David. (`test/reciclagem_model_test.dart`, `test/impacto_screen_test.dart`)
- Navegação: onde fica o guia de compostagem sem criar uma quinta tela — David. (`Docs/justificativas.md`)
