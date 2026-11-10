# LixoZero

Assistente doméstico de reciclagem: classifica cada resíduo (papel, plástico, vidro,
metal, orgânico, perigoso) e indica o destino correto mais próximo — ecopontos e cooperativas de
catadores.

## Missão

Reduzir o volume de resíduos enviados a lixões e aterros sanitários, educando a população
sobre separação correta, compostagem doméstica e logística reversa de recicláveis.

## Integrantes, Turma e Responsabilidades

**Turma:** Programação para Dispositivos Móveis - GP0029VNO07A

**Legenda:** [Sn] = Semana n (n = 1, 2, 3...)

| Integrante | Responsabilidades |
|---|---|
| Hapolo Luiz | [S1] Estudo de caso — 2.1 Problema, 2.2 Público e usuários, 2.7 Restrições e condições; [S2] Pesquisa e Apresentação; [S3] 2.1 Funcionalidades e Apresentação; [S5] Justificativas; [S6] Protótipo de Baixa Fidelidade, Protótipo de Alta Fidelidade e Apresentação |
| Caio Leal | [S1] Estudo de caso — 2.4 Objetivo e proposta de valor, 2.8 Pontos de atenção; [S2] Personas e Apresentação; [S3] 2.4 CRUD e Apresentação; [S6] Protótipo de Alta Fidelidade e Apresentação |
| Salatiel Batista | [S1] Estudo de caso — 2.3 Contexto de uso, 2.5 Personalidade, identidade e experiência; [S2] Benchmark e Apresentação; [S3] 2.2 Requisitos Funcionais e Apresentação; [S6] Protótipo de Baixa Fidelidade e Protótipo de Alta Fidelidade |
| David Cordeiro | [S1] Estudo de caso — 2.6 Funcionalidades e características já definidas; [S2] Pesquisa; [S3] 2.5 Priorizações e Apresentação; [S6] Protótipo de Baixa Fidelidade |
| Rafael Henrique | [S3] 2.3 Requisitos Não-Funcionais e Apresentação |

## Documentação

- [Estudo de caso](Docs/estudo-de-caso.md)
- [Pesquisa](Docs/pesquisa.md), [Benchmark](Docs/benchmark.md) e [Personas](Docs/personas.md)
- [Requisitos](Docs/requisitos.md)
- [Justificativas](Docs/justificativas.md)
- [Changelog](CHANGELOG.md)

## Status

Unidade II em andamento. Sprints 1 a 4 prontas:

- **Sprint 1:** busca offline "Onde jogo isso?" com o guia de 6 categorias e 81 itens (RF01, RF05)
- **Sprint 2:** tela de categorias e mapa de ecopontos e cooperativas de Aracaju (RF02, RF07, RF10)
- **Sprint 3:** registro de reciclagem e tela Impacto, com o contador de quilos e os lembretes
  de coleta com notificação (RF03, RF04, RF09)
- **Sprint 4:** guia de compostagem doméstica, aberto pela categoria Orgânico e pela busca,
  e dica rotativa no rodapé da busca (RF06)

Também tem login opcional com Firebase. Veja o [Changelog](CHANGELOG.md).

## Como rodar

Precisa do [Flutter](https://docs.flutter.dev/get-started/install) 3.47 ou mais novo, com
JDK 17 e Android SDK (ou Xcode, para iOS).

```bash
flutter pub get
flutter test   # testes
flutter run    # com um emulador ou celular conectado
```

**Chave do Google Maps:** o mapa precisa de uma chave da API (Maps SDK for Android/iOS),
que não vai para o Git:

- Android: em `android/local.properties`, coloque `MAPS_API_KEY=sua_chave`
- iOS: crie `ios/Flutter/Secrets.xcconfig` com `MAPS_API_KEY=sua_chave`

Sem a chave o mapa fica em branco, mas a lista de ecopontos continua aparecendo.

**Lembretes:** no Android 13 ou mais novo, o app pede permissão de notificação ao criar o
primeiro lembrete. No Android 14 ou mais novo, o aviso só chega no minuto exato se a opção
"Alarmes e lembretes" estiver ativada para o LixoZero; sem ela, o Android pode atrasar o
aviso em até 1 hora.

## Estrutura do código

| Pasta | O que tem |
|---|---|
| `assets/data/` | Guia de classificação, ecopontos/cooperativas, guia de compostagem e dicas (JSON editado pela equipe) |
| `assets/images/` | Poses do mascote Brotinho |
| `lib/data/` | Busca e leitura dos JSON |
| `lib/models/` | Categoria, item do guia, ponto de coleta, registro de reciclagem, lembrete, guia de compostagem e dica |
| `lib/services/` | Localização, login (Firebase) e notificações dos lembretes |
| `lib/state/` | Navegação, conexão, login, registros de reciclagem, lembretes e dica do rodapé |
| `lib/screens/` | Telas Buscar, Mapa, Impacto e Categorias, mais login, conta e compostagem |
| `test/` | Testes da busca, pontos de coleta, login, reciclagem, contador, lembretes, compostagem e dicas |

Para incluir ou corrigir um resíduo, edite `assets/data/guia.json` e rode `flutter test`,
que confere se todo item tem categoria, destino e peso. O mesmo vale para o guia de
compostagem (`compostagem.json`) e as dicas (`dicas.json`): o teste confere se nada ficou
vazio e se o item citado em cada dica existe no guia.

## Uso de inteligência artificial

O projeto foi feito em parceria com ferramentas de IA, como o Claude Code e o GPT.
O registro de como cada integrante usou a IA, com os erros gerados e as correções, está em
[Docs/uso-de-ia.md](Docs/uso-de-ia.md).
