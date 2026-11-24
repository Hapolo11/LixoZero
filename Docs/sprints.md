# Sprints do LixoZero



**Legenda:** ✅ feito · 🟡 em parte · ⬜ pendente · ➖ fora do escopo

## Visão geral

| Sprint | Conteúdo | Requisitos | Responsável | Situação |
|---|---|---|---|---|
| Unidade I | Estudo de caso, pesquisa, requisitos, justificativas e protótipos | — | Grupo | ✅ |
| 1 | Projeto Flutter, busca offline "Onde jogo isso?" | RF01, RF05 | Rafael | ✅ |
| 2 | Categorias, mapa de ecopontos e aviso sem internet | RF02, RF07, RF10 | Rafael | ✅ |
| Login | Login opcional com Firebase, conta e ícone | RNF06 | Hapolo | ✅ |
| 3 | Registro de reciclagem, contador e lembretes | RF03, RF04, RF09 | Salatiel (RF09) e Rafael | ✅ |
| 4 | Guia de compostagem e dica rotativa | RF06 | David | ✅ |
| 5 | Busca por foto e sincronização com o Firestore | RF08, RNF06 | Hapolo | ✅ |
| Diagramas | Casos de uso atualizado e diagrama de classes | — | Caio | ✅ |
| 6 | Polimento, acessibilidade, documentação e entrega | RNF, b-vi | Grupo (código: Rafael) | 🟡 código pronto; falta conferência no celular e merge |
| — | Dados para gestores e configuração por síndicos | RF11, RF12 | — | ➖ |

Verificação de 24/11/2026, na `unidade-2`: `flutter analyze` sem problemas e **152 testes passando**, e app rodando no emulador Android 15.

---

## Unidade I: documentação e protótipos ✅

| Entrega | Responsáveis | Arquivo |
|---|---|---|
| ✅ Estudo de caso | Hapolo, Caio, Salatiel e David | `Docs/estudo-de-caso.md` |
| ✅ Pesquisa, benchmark e personas | Hapolo, David, Salatiel e Caio | `Docs/pesquisa.md`, `benchmark.md`, `personas.md` |
| ✅ Requisitos (funcionalidades, RF, RNF, CRUD e priorização) | Hapolo, Salatiel, Rafael, Caio e David | `Docs/requisitos.md` |
| ✅ Justificativas de design | Hapolo | `Docs/justificativas.md` |
| ✅ Protótipos de baixa e alta fidelidade | David, Hapolo, Salatiel e Caio | `Docs/prototipo*.pdf` |
| ✅ Apresentações | Grupo | `Docs/apresentacao*.pdf` |
| ✅ Diagrama de casos de uso (atualizado na Unidade II) | Caio | `Docs/diagrama-casos-de-uso.pdf` |

---

## Sprint 1: busca offline ✅

**Objetivo:** responder "onde jogo isso?" sem internet.
**Requisitos:** RF01 (busca), RF05 (consulta offline), RNF01, RNF02, RNF03, RNF08.
**Commit:** `436acc7`, de Rafael.

- ✅ Projeto Flutter com o tema do protótipo: paleta, fontes Montserrat e Inter, modo claro fixo (RNF11)
- ✅ Navegação com 4 abas (Buscar, Mapa, Impacto, Categorias) e o mascote Brotinho (RNF10)
- ✅ Guia com 6 categorias e 81 itens em `assets/data/guia.json` (instrução, destino, sinônimos e peso médio)
- ✅ Busca em memória que aceita plural, falta de acento, maiúsculas e erro de digitação
- ✅ Tela "Onde jogo isso?" com resultado, dúvidas comuns e "não encontrei"
- ✅ Testes da busca (`test/busca_test.dart`), entre eles o caso "pilha" × "palha"
- ✅ Documentação ajustada antes do código: categoria Metal, RF09 reescrito, CRUD e priorização

## Sprint 2: categorias, mapa e conexão ✅

**Objetivo:** fechar o ciclo "sei a categoria, sei para onde levar".
**Requisitos:** RF02 (mapa), RF07 (cores), RF10 (sem internet), RNF09, RNF12, RNF13.
**Commit:** `436acc7`, de Rafael.

- ✅ Tela de categorias com código de cores, nome da lixeira e ícone; tocar num exemplo abre a busca
- ✅ 9 ecopontos da Emsurb e as cooperativas CARE, Coores e União, com fontes registradas
- ✅ Google Maps com a chave fora do Git (`local.properties` e `Secrets.xcconfig`)
- ✅ Localização, distância, ordenação, filtros por categoria, "Como chegar" e "Ligar"
- ✅ Aviso de sem internet, com a lista de pontos ainda visível
- ✅ Botão "Ver pontos de coleta" no resultado da busca
- ✅ Correção do mapa descartado duas vezes quando a internet cai
- ✅ Testes dos pontos de coleta (`test/pontos_test.dart`)

## Login opcional ✅

**Objetivo:** conta opcional, sem bloquear o app (RNF06). Ficou por último na priorização.
**Commit:** `aac5fb8`, de Hapolo.

- ✅ Telas de entrar, criar conta e recuperar senha, com "Não quero fazer login"
- ✅ E-mail e senha, e login com Google pelo Firebase Authentication, com erros em português
- ✅ Tela de conta: editar nome, sair e excluir a conta
- ✅ App funciona sem o `google-services.json` (`AuthIndisponivel`)
- ✅ Ícone adaptativo com o Brotinho
- ✅ Testes do login (`test/login_test.dart`)
- ✅ Seção do Hapolo no `Docs/uso-de-ia.md`

## Sprint 3: registro, contador e lembretes ✅

**Objetivo:** dar retorno ao usuário e ajudar a criar o hábito.
**Requisitos:** RF09 (registro), RF03 (contador), RF04 (lembretes), RNF07, RNF14.
**Commits:** `8e4c903`, de Salatiel (RF09), e `946af40`, de Rafael (RF03 e RF04).

- ✅ Botão "Registrar reciclagem" no resultado, que soma o peso médio, com "Registrado! +0,03 kg" e ajuste de peso (Salatiel)
- ✅ Tela Impacto com os quilos do mês e desde o começo, salvos só no aparelho
- ✅ Lembretes: criar, ver, editar e apagar com confirmação (CRUD completo)
- ✅ Notificação semanal no dia e horário escolhidos, com alarme exato quando o Android permite
- ✅ Aviso quando o usuário nega a permissão de notificação
- ✅ Ícone monocromático da notificação
- ✅ Correção do "Registrado!" que não sumia e cobria as outras abas
- ✅ Testes do registro, do contador, dos lembretes e das notificações
- ✅ Seção do Rafael no `Docs/uso-de-ia.md` (sprints 1 a 3)

## Sprint 4: compostagem e dica rotativa ✅

**Objetivo:** conteúdo educativo sem criar uma quinta tela (RNF10).
**Requisitos:** RF06.
**Commit:** `06984ca`, de David.

- ✅ Guia de compostagem doméstica em `assets/data/compostagem.json`: o que pode e o que não pode ir, passo a passo, chorume, problemas comuns e o que fazer sem espaço
- ✅ Acesso pelo card Orgânico, pelo resultado de itens orgânicos e pelas dicas
- ✅ Dica rotativa no rodapé da Buscar, com 8 dicas que mudam a cada busca e a cada abertura
- ✅ Card de categoria corrigido para fonte grande
- ✅ Testes do guia de compostagem e das dicas
- ✅ Seção do David no `Docs/uso-de-ia.md`
- ✅ Justificativa da navegação em `Docs/justificativas.md`, seção 4

---

## Sprint 5: busca por foto e Firestore ✅

**Objetivo:** sugerir o item a partir de uma foto e guardar os dados de quem tem conta na nuvem.
**Requisitos:** RF08 (imagem), RF03, RNF06 e RNF07.
**Commits:** `36ba38f` e `77ea679`, de Hapolo.

- ✅ Botão de câmera na busca, com câmera ou galeria (`image_picker`)
- ✅ Reconhecimento no próprio aparelho com o ML Kit (`google_mlkit_image_labeling`); a foto não sai do celular
- ✅ Mapa de rótulos para itens do guia em `assets/data/rotulos.json`
- ✅ Até 3 sugestões para o usuário confirmar e mensagem quando a foto não é reconhecida
- ✅ Registros de reciclagem e lembretes gravados no Firestore (`usuarios/{uid}`) para quem tem conta, com cópia no aparelho e envio quando a internet volta
- ✅ Sincronização ao entrar na conta e quando a conexão volta, com o estado na tela Conta
- ✅ Excluir a conta apaga antes os dados da nuvem
- ✅ Regras de segurança em `firestore.rules`: cada usuário só acessa o que é dele
- ✅ Quem escolhe "Não quero fazer login" continua só com os dados do aparelho
- ✅ Telas de login refeitas para ficar fiéis ao protótipo de alta fidelidade
- ✅ Testes da sincronização e da busca por foto (`test/sincronizacao_test.dart`, `test/busca_por_foto_test.dart`)
- ✅ RF03, RF08, RNF07 e CRUD ajustados em `Docs/requisitos.md`
- ✅ Seção do Hapolo no `Docs/uso-de-ia.md` atualizada

## Diagramas da Unidade II ✅

**Commits:** `4480fcf` e `a64d054`, de Caio.

- ✅ Diagrama de casos de uso atualizado com a busca por foto, a sincronização e a revisão dos atores
- ✅ Diagrama de classes (`Docs/diagrama-de-classes.pdf`)
- ✅ Seção do Caio no `Docs/uso-de-ia.md`

---

## Sprint 6: polimento e entrega ⬜

**Objetivo:** fechar a Unidade II com o app revisado e a documentação completa.

### Conteúdo e dados

- ⬜ Grupo conferir os pesos médios estimados dos 81 itens (marcado como pendente no `uso-de-ia.md`)
- ⬜ Confirmar o horário das cooperativas CARE, Coores e União (hoje o app mostra "Ligue antes de ir")
- ⬜ Conferir os 4 ecopontos sem número no endereço ("posição aproximada")

### Busca por foto e Firestore

- ✅ **Permissões de câmera e galeria no iOS:** `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` no `ios/Runner/Info.plist` (Rafael, 24/11)
- ✅ Regras do `firestore.rules` publicadas no console do Firebase
- ⬜ Testar a busca por foto no celular real com itens comuns (garrafa PET, lata, papelão, casca de fruta) e ampliar o `rotulos.json` se precisar
- ⬜ Testar a sincronização em dois celulares com a mesma conta e a exclusão da conta

### Acessibilidade e qualidade

- ⬜ Passar o TalkBack (Android) e o VoiceOver (iOS) nas 4 abas e nas telas de login, conta e compostagem
- ✅ Rótulos de leitor de tela nos botões só com ícone, conferidos pelo `labeledTapTargetGuideline` em todas as telas (`test/acessibilidade_test.dart`). O mascote fica fora do leitor de propósito, porque é enfeite e tudo o que ele "diz" está em texto; os marcadores do mapa usam o nome do ponto, e a lista abaixo do mapa tem os mesmos pontos
- ✅ Fonte do sistema em 200% em todas as telas, por teste automático e no emulador. Corrigidos: Buscar estourando a altura, nomes das abas quebrando no meio da palavra e textos estourando a largura
- ✅ Contraste de 4,5:1 conferido pelo `textContrastGuideline`. Corrigido o verde escuro sobre o verde claro (4,35:1 → 5,66:1) no filtro do Mapa e no botão "Ativar"
- ✅ Áreas de toque de 48 dp conferidas pelo `androidTapTargetGuideline`. Corrigidos os filtros do Mapa, que tinham 36 dp
- ✅ RNF01 e RNF02 medidos e anotados no README
- ⬜ Rodar num celular de entrada, ou num emulador com pouca memória (RNF04)
- ⬜ Teste de ponta a ponta no celular real: buscar, registrar, ver o contador, criar lembrete, receber a notificação, mapa com e sem internet, compostagem, busca por foto, login, sincronização e "Não quero fazer login"
- 🟡 iOS mínimo passou para 15.5 no `Podfile` e no `project.pbxproj` (Rafael, 24/11). Falta compilar num Mac com Xcode e testar notificações e câmera no simulador ou no iPhone. Para o login e o Firestore no iOS também falta o `ios/Runner/GoogleService-Info.plist` (sem ele o app abre sem conta, como no Android sem o `google-services.json`)

### Documentação e entrega

- ✅ Seções de todos os integrantes no `Docs/uso-de-ia.md` (Hapolo, Rafael, Caio, Salatiel e David)
- ✅ README com o status da Unidade II e as medições de RNF01 e RNF02
- 🟡 CHANGELOG com a sprint 6 (24/11); falta a linha final da entrega
- ⬜ Merge do PR #1 (`unidade-2` → `main`)

---

## Fora do escopo ➖

- ➖ **RF11:** dados agregados para gestores públicos
- ➖ **RF12:** configuração de coleta por síndicos

Os dois exigem servidor próprio, o que contraria o funcionamento offline e sem coleta de dados do protótipo (`requisitos.md`, seção 2.5).

## Cobertura dos requisitos

| Requisito | Situação | Onde |
|---|---|---|
| RF01 Busca | ✅ | Sprint 1 |
| RF02 Mapa | ✅ | Sprint 2 |
| RF03 Contador | ✅ | Sprint 3 |
| RF04 Lembretes | ✅ | Sprint 3 |
| RF05 Offline | ✅ | Sprint 1 |
| RF06 Compostagem | ✅ | Sprint 4 |
| RF07 Cores | ✅ | Sprint 2 |
| RF08 Imagem | ✅ | Sprint 5 |
| RF09 Registro | ✅ | Sprint 3 |
| RF10 Sem internet | ✅ | Sprint 2 |
| RF11 e RF12 | ➖ | Fora do escopo |
| RNF01, RNF02, RNF04 (desempenho e usabilidade) | ⬜ medir | Sprint 6 |
| RNF03, RNF05 a RNF16 | ✅ | Sprints 1 a 5 |
