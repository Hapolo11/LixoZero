# Sprints do LixoZero



**Legenda:** ✅ feito · ⬜ pendente · ➖ fora do escopo

## Visão geral

| Sprint | Conteúdo | Requisitos | Responsável | Situação |
|---|---|---|---|---|
| Unidade I | Estudo de caso, pesquisa, requisitos, justificativas e protótipos | — | Grupo | ✅ |
| 1 | Projeto Flutter, busca offline "Onde jogo isso?" | RF01, RF05 | Rafael | ✅ |
| 2 | Categorias, mapa de ecopontos e aviso sem internet | RF02, RF07, RF10 | Rafael | ✅ |
| Login | Login opcional com Firebase, conta e ícone | RNF06 | Hapolo | ✅ |
| 3 | Registro de reciclagem, contador e lembretes | RF03, RF04, RF09 | Salatiel (RF09) e Rafael | ✅ |
| 4 | Guia de compostagem e dica rotativa | RF06 | David | ✅ |
| 5 | Reconhecimento de imagem (opcional) | RF08 | a definir | ⬜ |
| 6 | Polimento, acessibilidade, documentação e entrega | RNF, b-vi | Grupo | ⬜ |
| — | Dados para gestores e configuração por síndicos | RF11, RF12 | — | ➖ |

Verificação feita hoje: `flutter analyze` sem problemas e **100 testes passando**.

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
| ✅ Diagrama de casos de uso | Caio | `Docs/diagrama-casos-de-uso.pdf` |

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

## Sprint 5: reconhecimento de imagem (RF08) ⬜ opcional

**Objetivo:** sugerir a categoria a partir de uma foto.
**Prioridade:** secundária, "diferencial futuro, não é essencial para o MVP" (`requisitos.md` 2.5).

Escolha antes de começar:

- ⬜ **Opção A, implementar:** câmera com `image_picker`, rótulos com o ML Kit no próprio aparelho (`google_mlkit_image_labeling`, offline), uma tabela que liga rótulo ao item do guia e a busca já existente. A foto não sai do aparelho (RNF06). O usuário confirma a sugestão antes de ver o resultado.
- ⬜ **Opção B, não implementar:** registrar a decisão no CHANGELOG e na priorização (`requisitos.md` 2.5) como "não entregue na Unidade II", com o motivo.

Se for a opção A:

- ⬜ Botão de câmera no campo de busca
- ⬜ Mapa de rótulos para itens (`assets/data/rotulos.json`) e teste que confere se todo item citado existe no guia
- ⬜ Mensagem quando a foto não for reconhecida, levando para a busca por texto
- ⬜ Permissão de câmera no Android e no iOS
- ⬜ Testes com rotulador falso, no mesmo padrão de `Notificacoes` e `AuthRepositorio`
- ⬜ Teste no emulador e no celular, e linha no CHANGELOG

## Sprint 6: polimento e entrega ⬜

**Objetivo:** fechar a Unidade II com o app revisado e a documentação completa.

### Conteúdo e dados

- ⬜ Grupo conferir os pesos médios estimados dos 81 itens (marcado como pendente no `uso-de-ia.md`)
- ⬜ Confirmar o horário das cooperativas CARE, Coores e União (hoje o app mostra "Ligue antes de ir")
- ⬜ Conferir os 4 ecopontos sem número no endereço ("posição aproximada")

### Acessibilidade e qualidade

- ⬜ Passar o TalkBack (Android) e o VoiceOver (iOS) nas 4 abas e nas telas de login, conta e compostagem
- ⬜ Rótulos de leitor de tela (`Semantics`, `tooltip`) nos botões só com ícone, no mascote e nos marcadores do mapa
- ⬜ Testar com a fonte do sistema no máximo em todas as telas, não só nas Categorias
- ⬜ Conferir o contraste de 4,5:1 nos textos sobre as cores das categorias (`justificativas.md`, seção 6)
- ⬜ Conferir as áreas de toque de pelo menos 48 dp
- ⬜ Medir o RNF01 (resultado em até 3 s) e o RNF02 (até 3 interações) e anotar no README
- ⬜ Rodar num celular de entrada, ou num emulador com pouca memória (RNF04)
- ⬜ Teste de ponta a ponta no celular real: buscar, registrar, ver o contador, criar lembrete, receber a notificação, mapa com e sem internet, compostagem, login e "Não quero fazer login"
- ⬜ Testar o build de iOS de novo depois das sprints 3 e 4 (as notificações mexeram no `AppDelegate.swift`)

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
| RF08 Imagem | ⬜ | Sprint 5 (opcional) |
| RF09 Registro | ✅ | Sprint 3 |
| RF10 Sem internet | ✅ | Sprint 2 |
| RF11 e RF12 | ➖ | Fora do escopo |
| RNF01, RNF02, RNF04 (desempenho e usabilidade) | ⬜ medir | Sprint 6 |
| RNF03, RNF05 a RNF16 | ✅ | Sprints 1 a 4 |
