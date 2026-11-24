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
- [Modelagem do banco de dados](Docs/modelagem-banco.md)
- [Justificativas](Docs/justificativas.md)
- [Plano das sprints](Docs/sprints.md)
- [Changelog](CHANGELOG.md)

## Status

Unidade II concluída. Todas as sprints prontas, dados conferidos pelo grupo e app testado e
rodando no celular Android e no iOS (veja `Docs/sprints.md`).

- **Sprint 1:** busca offline "Onde jogo isso?" com o guia de 6 categorias e 81 itens (RF01, RF05)
- **Sprint 2:** tela de categorias e mapa de ecopontos e cooperativas de Aracaju (RF02, RF07, RF10)
- **Sprint 3:** registro de reciclagem e tela Impacto, com o contador de quilos e os lembretes
  de coleta com notificação (RF03, RF04, RF09)
- **Sprint 4:** guia de compostagem doméstica, aberto pela categoria Orgânico e pela busca,
  e dica rotativa no rodapé da busca (RF06)

- **Firestore:** quem tem conta também guarda os registros e os lembretes na nuvem, e eles
  voltam ao entrar de novo ou em outro celular. Sem conta, tudo fica só no aparelho
- **Busca por foto (RF08):** o botão de câmera da busca sugere o item pela foto, no próprio
  aparelho, e o usuário confirma

- **Sprint 6:** acessibilidade conferida por testes automáticos em todas as telas (área de
  toque de 48 dp, nomes para o leitor de tela, contraste de 4,5:1 e fonte em 200%), permissões
  de câmera e galeria no iOS e iOS mínimo 15.5

Também tem login opcional com Firebase. Veja o [Changelog](CHANGELOG.md).

### Medições (RNF01 e RNF02)

Medidas em 24/11/2026 no emulador Android 15 (Pixel) e nos testes automáticos:

- **RNF01 (resultado em até 3 s):** a busca roda em memória e leva menos de 50 ms por consulta
  no guia inteiro (`test/busca_test.dart`). No emulador, o resultado aparece assim que se
  toca em Buscar, inclusive com erro de digitação ("pilhs" encontra Pilha).
- **RNF02 (até 3 interações):** tocar no campo, digitar e tocar em Buscar. As "Dúvidas comuns"
  e as sugestões da busca por foto resolvem em 1 toque.

## Como rodar

Precisa do [Flutter](https://docs.flutter.dev/get-started/install) 3.47 ou mais novo, com
JDK 17 e Android SDK (ou Xcode, para iOS).

```bash
flutter pub get
flutter test   # testes
flutter run    # com um emulador ou celular conectado
```

Sem emulador ou celular, dá para abrir no navegador com `flutter run -d chrome`. Na web o
login e a sincronização ficam desligados (o Firebase só está configurado para Android e iOS), o
app funciona como visitante e a busca por foto pode não funcionar.

**Chave do Google Maps:** o mapa precisa de uma chave da API (Maps SDK for Android/iOS),
que não vai para o Git:

- Android: em `android/local.properties`, coloque `MAPS_API_KEY=sua_chave`
- iOS: crie `ios/Flutter/Secrets.xcconfig` com `MAPS_API_KEY=sua_chave`
- Web: sem chave, o mapa aparece escurecido com a marca "for development purposes only". Para o
  mapa normal, troque o script em `web/index.html` por `maps/api/js?key=sua_chave`, com a Maps
  JavaScript API ativada na chave (não faça commit da chave)

Sem a chave o mapa fica em branco, mas a lista de ecopontos continua aparecendo.

**Lembretes:** no Android 13 ou mais novo, o app pede permissão de notificação ao criar o
primeiro lembrete. No Android 14 ou mais novo, o aviso só chega no minuto exato se a opção
"Alarmes e lembretes" estiver ativada para o LixoZero; sem ela, o Android pode atrasar o
aviso em até 1 hora.

**Firebase:** o login e o Firestore precisam do projeto no Firebase. O arquivo
`android/app/google-services.json` já está no repositório. Para a sincronização funcionar,
no console do Firebase crie o Firestore Database e publique o conteúdo de `firestore.rules`
(Firestore Database > Regras). Não use o "modo de teste", que deixa o banco aberto para
qualquer pessoa. Sem o Firestore, o app continua funcionando e a tela Conta avisa que não
foi possível sincronizar.

No iOS, a entrega vai sem o `ios/Runner/GoogleService-Info.plist`: o app abre e funciona
inteiro como visitante (busca, mapa, impacto, lembretes, compostagem e busca por foto), só
sem login e sem sincronização. Para ligar o Firebase no iOS, baixe o arquivo no console do
Firebase (app iOS com o bundle id do projeto) e coloque em `ios/Runner/`.

**Busca por foto:** o reconhecimento é do ML Kit e roda sem internet. A tabela que liga os
rótulos dele aos itens do guia é `assets/data/rotulos.json`. Se uma foto não for reconhecida,
acrescente ali o rótulo que o ML Kit devolveu.

## Estrutura do código

| Pasta | O que tem |
|---|---|
| `assets/data/` | Guia de classificação, ecopontos/cooperativas, guia de compostagem, dicas e rótulos da busca por foto (JSON editado pela equipe) |
| `assets/images/` | Poses do mascote Brotinho |
| `lib/data/` | Busca e leitura dos JSON |
| `lib/models/` | Categoria, item do guia, ponto de coleta, registro de reciclagem, lembrete, guia de compostagem e dica |
| `lib/services/` | Localização, login e Firestore (Firebase), notificações dos lembretes, câmera e reconhecimento de imagem |
| `lib/state/` | Navegação, conexão, login, sincronização com o Firestore, registros de reciclagem, lembretes e dica do rodapé |
| `lib/screens/` | Telas Buscar, Mapa, Impacto e Categorias, mais login, conta e compostagem |
| `test/` | Testes da busca, pontos de coleta, login, sincronização, busca por foto, reciclagem, contador, lembretes, compostagem, dicas e acessibilidade |

Para incluir ou corrigir um resíduo, edite `assets/data/guia.json` e rode `flutter test`,
que confere se todo item tem categoria, destino e peso. O mesmo vale para o guia de
compostagem (`compostagem.json`) e as dicas (`dicas.json`): o teste confere se nada ficou
vazio e se o item citado em cada dica existe no guia.

## Uso de inteligência artificial

O projeto foi feito em parceria com ferramentas de IA, como o Claude Code e o GPT.
O registro de como cada integrante usou a IA, com os erros gerados e as correções, está em
[Docs/uso-de-ia.md](Docs/uso-de-ia.md).
