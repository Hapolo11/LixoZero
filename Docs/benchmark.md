# 3. Benchmark

Análise de 3 soluções existentes relacionadas ao problema de descarte e classificação de resíduos.

---

## 3.1. Cataki

App brasileiro que conecta moradores a catadores autônomos e cooperativas de reciclagem, funcionando como uma espécie de "match" entre quem tem material reciclável e quem faz a coleta.

**Principais funcionalidades**
- Cadastro de catadores e cooperativas com localização no mapa.
- Solicitação de coleta: o morador publica o material disponível e combina retirada com o catador mais próximo.
- Comunicação direta entre morador e catador para agendar dia/horário.

**Pontos positivos**
- Fortalece a renda de catadores autônomos, dando visibilidade a um elo importante da cadeia de reciclagem.
- Gratuito e sem intermediação financeira obrigatória.
- Resolve bem o problema de "quem leva o material", não só "onde jogar".

**Pontos negativos**
- Depende do número de catadores cadastrados na região; em cidades menores a cobertura é baixa.
- Não ajuda o usuário a saber como classificar o resíduo antes de descartar — pressupõe que a pessoa já separou tudo corretamente.
- Fluxo de agendamento tem mais etapas (publicar material, aguardar contato, combinar horário), o que não é rápido o suficiente para uma dúvida do tipo "onde jogo isso agora".

**Aspectos de interface/experiência**
- Interface simples, com foco em localização em mapa e mensagens, mas voltada a quem já decidiu reciclar — não a quem está com dúvida na hora do descarte.

---

## 3.2. Descarte Rápido

App brasileiro que indica, por geolocalização, os pontos de coleta mais próximos para diferentes tipos de resíduo, incluindo parcerias com programas de logística reversa (como embalagens longa-vida e materiais de escrita).

**Principais funcionalidades**
- Busca de pontos de coleta próximos por tipo de material.
- Cadastro de pessoas físicas e empresas.
- Parcerias com marcas e iniciativas de logística reversa, que ampliam a lista de itens aceitos.

**Pontos positivos**
- Foco claro em resolver "onde levar", com boa cobertura de pontos de coleta específicos (pilhas, embalagens, materiais de escrita).
- Parcerias ampliam a utilidade do app sem custo para o usuário.

**Pontos negativos**
- Depende de internet o tempo todo; não há guia de classificação offline.
- Não orienta sobre a categoria do resíduo (reciclável, orgânico, perigoso) antes de buscar o ponto de coleta — o usuário precisa já saber o que tem em mãos.
- Sem contador de impacto ou reforço motivacional para manter o hábito.

**Aspectos de interface/experiência**
- Interface funcional, orientada a busca e mapa, mas com tom mais informativo/institucional do que educativo ou comunitário.

---

## 3.3. Recycle Coach

App internacional (usado por prefeituras nos EUA, Canadá e Reino Unido) que ajuda moradores a saber como descartar cada item, além de lembrar datas de coleta.

**Principais funcionalidades**
- Ferramenta de busca "What Goes Where": digita-se o nome do item e o app diz em qual lixeira/categoria ele se encaixa, segundo as regras locais.
- Reconhecimento de imagem: tira-se uma foto do item e o app sugere a forma correta de descarte.
- Calendário e lembretes de coleta, com avisos de mudanças em feriados.
- Conteúdo educativo (quizzes e dicas) sobre reciclagem.

**Pontos positivos**
- Resposta rápida e direta por busca de texto, resolvendo exatamente a dúvida "onde jogo isso" — a mesma necessidade central do LixoZero.
- Lembretes de coleta reduzem o acúmulo de lixo e ajudam a criar hábito.
- Reconhecimento por imagem é um diferencial de usabilidade para quem não sabe nem o nome do item.

**Pontos negativos**
- As respostas dependem das regras do município cadastrado; fora das cidades parceiras, o app perde grande parte da utilidade.
- Não tem função offline — cada busca depende de conexão.
- Não conecta o usuário a cooperativas de catadores nem tem foco social/comunitário, é mais institucional (prefeitura/usuário).

**Aspectos de interface/experiência**
- Interface de busca simples e direta (parecida com um mecanismo de busca), com bom uso de calendário visual; tom mais neutro/institucional do que motivador.

---

## 3.4. O que pode ser aproveitado ou melhorado no projeto

- **Do Cataki:** a ideia de conectar diretamente o usuário a cooperativas e catadores pode ser aproveitada na função de mapa do LixoZero, mas sem depender de negociação manual — o app pode apenas indicar o ponto/cooperativa mais próxima, mantendo o fluxo rápido.
- **Do Descarte Rápido:** as parcerias de logística reversa mostram que vale a pena, no futuro, ampliar a lista de itens "especiais" (pilhas, eletrônicos, embalagens longa-vida) além das categorias básicas de cor.
- **Do Recycle Coach:** a busca por texto tipo "What Goes Where" é praticamente o mesmo modelo que o LixoZero já propõe ("Onde jogo isso?"), o que valida a escolha de foco em busca rápida. O reconhecimento de imagem e o calendário de lembretes são bons exemplos de funcionalidades que aumentam a usabilidade sem complicar o fluxo principal.

## O que o LixoZero poderá fazer de diferente ou melhor?

O Cataki depende de negociação manual e de internet o tempo todo; o Descarte Rápido indica onde descartar, mas não ensina a classificar; e o Recycle Coach, apesar da busca parecida, não funciona offline nem se conecta a cooperativas de catadores. O LixoZero se diferencia justamente por unir tudo isso num só app leve: guia de classificação offline, mapa com prioridade para cooperativas, sem cadastro nem depender de prefeitura, além do contador de impacto para manter o hábito.
