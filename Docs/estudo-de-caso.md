# Atividade 01 — Análise do Estudo de Caso

**Projeto:** LixoZero

**Disciplina:** Programação para Dispositivos Móveis

**Responsável pela seção:** Hapolo Luiz Silva Ramos dos Santos, Caio Leal Paixão

## 2.1. Problema

**Qual problema o aplicativo pretende ajudar a solucionar?**

O LixoZero ataca o descarte incorreto de resíduos domésticos, um dos fatores que aumenta o volume de lixo enviado a lixões e aterros sanitários. O problema não é "falta de reciclagem", mas falta de conhecimento prático, as pessoas querem reciclar, mas não sabem em qual categoria cada resíduo se encaixa ("Onde jogo uma lâmpada? E uma casca de banana?"). O app também resolve a dificuldade de localizar pontos de coleta seletiva e cooperativas próximas, seguindo a lógica de prioridade da PNRS (Lei 12.305/2010, Art. 9º): não geração, redução, reutilização, reciclagem e só por último descarte, daí o app também estimular compostagem, não só classificação.

**Por que esse problema é relevante?**

Lixões mal geridos liberam metano (gás 21x mais potente que o CO2 no aquecimento global), contaminam lençóis freáticos e favorecem doenças, problema que a própria PNRS foi criada para enfrentar. No plano global, o ODS 12 tem como meta reduzir substancialmente a geração de resíduos e garantir acesso à informação sobre consumo sustentável, e o ODS 11 mira reduzir o impacto ambiental das cidades e acabar com os lixões, ambos diretamente conectados à missão do app.

**Qual é a principal necessidade que a solução deverá atender?**

Resposta rápida e confiável sobre "onde jogar isso" (até 3 segundos, offline), resolvendo a dúvida no momento em que ela surge. Secundariamente, manter o usuário engajado via contador de impacto, reforçando o comportamento ao longo do tempo.

## 2.2. Público e usuários

- **Famílias urbanas:** usuárias recorrentes, precisam de resposta simples e rápida no momento da separação do lixo (cozinha/varanda), sem depender de internet.
- **Síndicos de condomínios:** usam o app pra organizar a coleta seletiva do prédio, orientando moradores sobre dias e locais de descarte.
- **Cooperativas de catadores:** recebem os resíduos direcionados pelo mapa do app. A PNRS formalizou a inclusão desse grupo na logística reversa e coleta seletiva, e a atividade também está ligada aos ODS 1 e 8 (renda e trabalho decente gerados pela cadeia de reciclagem).
- **Escolas:** usam o app como ferramenta didática em projetos pedagógicos sobre meio ambiente e economia circular.
- **Gestores públicos:** usam dados agregados e anônimos de impacto pra apoiar planejamento da coleta seletiva municipal, alinhado aos instrumentos previstos na PNRS.

## 2.4 Objetivo e proposta de valor

**O que o aplicativo pretende oferecer e qual benefício deverá proporcionar ao usuário?**

O aplicativo tem como objetivo funcionar como um assistente de reciclagem doméstica, classificando cada resíduo informado pelo usuário e indicando o destino correto mais próximo, como por exemplo ecopontos e cooperativas de catadores. A proposta de valor do aplicativo consiste em tornar a vida do usuário que não sabe separar corretamente ou não conhece os pontos de coleta perto de casa mais fácil. O aplicativo tem como objetivo final ajudar a reduzir o volume de resíduos recicláveis que acabam em lixões e aterros, além de gerar consciência ambiental por meio do acompanhamento do impacto gerado pelo próprio usuário.

## 2.7. Restrições e condições

- **Quantidade de telas:** o protótipo deve ter no máximo 4 telas principais, "Onde jogo isso?", categorias de resíduos, ecopontos/cooperativas e contador de reciclagem.
- **Número de interações:** a funcionalidade principal deve ocorrer em até 3 interações (Abrir > Digitar o resíduo > Tocar em "Buscar" > Ver o resultado), com resposta exibida em menos de 3 segundos.
- **Dispositivos:** o app deve rodar em smartphones básicos, o que limita o uso de recursos pesados de processamento ou gráficos complexos.
- **Conectividade:** o guia de classificação precisa funcionar sem internet, enquanto o mapa de ecopontos depende de conexão (por usar Google Maps).
- **Privacidade:** o app não pode coletar dados de identificação dos usuários; o cálculo de impacto (quilos reciclados) deve ser anônimo e processado localmente.
- **Navegação e acessibilidade:** é obrigatório o uso do código de cores universal da reciclagem (azul para papel, vermelho para plástico, verde para vidro), já que isso facilita a separação imediata pelo usuário, inclusive em situações de baixa atenção ou letramento.
- **Ambiente de utilização:** o app será usado principalmente em cozinhas, varandas e escolas, o que exige foco no modo claro (não é prioridade oferecer modo escuro).
- **Integração externa:** o mapa de ecopontos e cooperativas deve usar a API do Google Maps, o que é uma dependência técnica externa a ser considerada no desenvolvimento.
- **Documentação obrigatória:** o time deve manter, na pasta /docs do repositório GitHub, o Documento de Requisitos + Personas + Pesquisas (com base na PNRS), a justificativa das decisões visuais ligadas à educação ambiental, e um CHANGELOG.md registrando as mudanças feitas no protótipo.

## 2.8 Pontos de atenção

**Quais são os 3 aspectos do estudo de caso que consideramos mais importantes para o sucesso do aplicativo?**

**Rapidez na resposta**
 
A gente considerou esse o ponto mais importante porque é isso que decide se a pessoa vai usar o app de verdade ou vai desistir no meio do caminho. Ninguém vai ficar esperando o celular carregar para saber onde jogar uma pilha ou uma casca de banana, se o aplicativo demorar, o usuário simplesmente joga no lixo comum mesmo e esquece do aplicativo.

**Funcionar offline**

Esse ponto é importante porque nem todo mundo tem internet boa em casa o tempo todo, principalmente em bairros mais afastados ou em famílias de renda mais baixa, que são parte do público que a gente quer atingir. Então garantir que a parte de identificar o tipo de resíduo funcione sem internet é o que vai fazer o app ser acessível de verdade.

**Simplicidade da interface**

A gente escolheu esse aspecto porque o público do app não é só gente que entende de tecnologia, no nosso público alvo temos criança na escola, tem gente mais velha, tem quem nunca usou um app parecido. Se o caminho para usar o app for complicado, a adesão cai. Limitar a três passos (abrir, digitar o resíduo, ver o resultado) força o time a pensar num design enxuto, o que ajuda tanto na usabilidade quanto na educação ambiental, porque a informação chega de forma direta e rápida.
