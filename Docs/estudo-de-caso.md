# Atividade 01 — Análise do Estudo de Caso

**Projeto:** LixoZero

**Disciplina:** Programação para Dispositivos Móveis

**Responsável pela seção:** Hapolo Luiz Silva Ramos dos Santos, Caio Leal Paixão, Salatiel Batista Santos

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

## 2.3. Contexto de uso

**Identifique os diferentes contextos nos quais o aplicativo poderá ser utilizado. Considere as informações fornecidas no estudo de caso, como:**

- **Ambiente:** Usado em casas e escolas, não em campo aberto. Isso pede interface simples, sem recursos técnicos complexos, com modo claro por padrão. 
- **Momento de utilização:** Famílias usam semanalmente, escolas usam em projetos pontuais. O app precisa ser rápido de consultar, já que é aberto só na hora de descartar algo. 
- **Condições do usuário:** Público vai de famílias a catadores e gestores públicos, com níveis de familiaridade digital muito diferentes. Por isso a interface precisa ser simples, com poucas telas e linguagem clara para todos. 
- **Dispositivo:** Rodar em celulares básicos limita o app tecnicamente: sem processamento pesado, com imagens leves e função offline no guia de classificação. 
- **Conectividade:** Muitos usuários têm internet fraca, então as funções essenciais precisam funcionar offline, deixando online só o que exige dados atualizados, como o mapa. 
- **Iluminação:** Uso em ambientes internos e iluminados reforça o modo claro e cores de alto contraste para facilitar a leitura rápida.  
- **Nível de atenção:** Como o uso ocorre com as mãos ocupadas e pouca atenção disponível, o app precisa responder rápido e exigir poucos toques.  
- **Situação de urgência:** O descarte costuma ser imediato, então o app precisa ser ágil e funcionar sem depender de conexão. 
- **Outras condições específicas:** Não coleta dados pessoais, o que gera confiança. Nas escolas, funciona também como ferramenta educativa. E pode futuramente mostrar dados agregados para síndicos e cooperativas.

O Aplicativo atende situações rápidas do dia a dia, em casa ou na escola, para um público variado e quase sempre apressado. Como muitos usuários têm internet fraca e celulares simples, o app precisa ser leve, funcionar offline nas partes principais e responder em poucos segundos, com no máximo três toques. A interface usa cores já conhecidas (azul para papel, vermelho para plástico, verde para vidro) e visual claro. Ou seja: o contexto de uso pede praticidade e agilidade acima de qualquer sofisticação técnica. 

## 2.4 Objetivo e proposta de valor

**O que o aplicativo pretende oferecer e qual benefício deverá proporcionar ao usuário?**

O aplicativo tem como objetivo funcionar como um assistente de reciclagem doméstica, classificando cada resíduo informado pelo usuário e indicando o destino correto mais próximo, como por exemplo ecopontos e cooperativas de catadores. A proposta de valor do aplicativo consiste em tornar a vida do usuário que não sabe separar corretamente ou não conhece os pontos de coleta perto de casa mais fácil. O aplicativo tem como objetivo final ajudar a reduzir o volume de resíduos recicláveis que acabam em lixões e aterros, além de gerar consciência ambiental por meio do acompanhamento do impacto gerado pelo próprio usuário.

## 2.5. Personalidade, identidade e experiência

**Analise:**
- **Palavras conceituais:** Termos como reciclagem, compostagem, logística reversa e economia circular moldam a linguagem do app, reforçando tanto a consequência do descarte errado quanto possíveis funções futuras, como conectar usuários a cooperativas. 
- **Personalidade da identidade:** Didática, verde e comunitária. Isso evita um tom técnico ou corporativo e aproxima o app de uma experiência simples e educativa, valorizando também o impacto coletivo, não só o individual. 
-- **Tom da interface:** Educativo e motivador. Os feedbacks devem reforçar sensação de progresso e pertencimento, como no contador de "quilos reciclados", em vez de apenas confirmar ações. 
- **Tom da experiência do usuário:** Segue a mesma lógica motivadora, mas aplicada a todo o fluxo de uso, evitando fricção ou linguagem punitiva mesmo quando o usuário erra. 
- **Forma como o aplicativo deseja ser lembrado:** Pela frase "o assistente que transforma lixo em consciência", que serve de guia para todas as decisões do produto.
- 
**Explique como essas características deverão influenciar a solução. Não é necessário desenvolver a identidade visual nesta atividade.**
No geral, essas características pedem um app com linguagem simples e educativa, tom motivador e voltado à comunidade, priorizando clareza pedagógica acima de sofisticação técnica e medindo o sucesso pela mudança de consciência ambiental que gera no usuário.

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
