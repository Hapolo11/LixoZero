## 2.1. Funcionalidades

### 1. Guia de classificação de resíduos (busca por texto)

**Descrição:** O usuário digita o nome do item que quer descartar (ex: "pilha", "casca de banana", "isopor") e o app retorna a categoria correta e orientação de descarte.

**Necessidade do usuário que atende:** Saber, na hora da dúvida, em qual categoria um resíduo se encaixa, sem depender de reconhecer símbolos ou embalagens.

**Justificativa:** É a funcionalidade central do produto. A pesquisa mostrou que 58% dos brasileiros não reconhecem os símbolos de reciclagem, então a resposta do app não pode depender de o usuário já saber a categoria. É também a necessidade mais citada pela persona prioritária, Marina Costa, que busca uma resposta rápida sem termos técnicos.

### 2. Mapa de ecopontos, cooperativas e pontos de coleta

**Descrição:** Exibe, num mapa (via Google Maps), os pontos de descarte mais próximos do usuário, com prioridade para cooperativas de catadores.

**Necessidade do usuário que atende:** Saber para onde levar fisicamente o resíduo depois de identificá-lo.

**Justificativa:** A pesquisa apontou que só 35% dos brasileiros acham fácil encontrar informação local sobre coleta seletiva. No benchmark, nenhum concorrente resolve bem os dois problemas ao mesmo tempo (classificar e indicar onde levar), então essa funcionalidade é o que fecha o ciclo completo do usuário.

### 3. Contador de impacto (quilos reciclados)

**Descrição:** Mostra ao usuário, de forma acumulada e anônima, quantos quilos de resíduos ele já deixou de enviar a lixões ou aterros.

**Necessidade do usuário que atende:** Ver resultado concreto do próprio esforço, o que mantém a motivação para continuar reciclando.

**Justificativa:** A pesquisa identificou que a falta de feedback é uma das causas de as pessoas desistirem de reciclar com regularidade. As personas Marina e Ana Beatriz valorizam explicitamente "ver resultado" do que fizeram, o que reforça essa funcionalidade como ferramenta de retenção, não só um enfeite visual.

### 4. Lembretes de coleta seletiva

**Descrição:** Notifica o usuário sobre os dias e horários da coleta seletiva na sua região.

**Necessidade do usuário que atende:** Evitar esquecer o dia da coleta e acumular lixo reciclável em casa.

**Justificativa:** Funcionalidade já prevista no estudo de caso, e validada pelo benchmark: o Recycle Coach mostrou que lembretes de coleta ajudam a criar hábito, algo que reforça o objetivo de engajamento contínuo do LixoZero.

### 5. Guia de classificação disponível offline

**Descrição:** Permite consultar a classificação de resíduos mesmo sem conexão com a internet.

**Necessidade do usuário que atende:** Conseguir usar o app mesmo com internet fraca ou instável, especialmente em ambientes domésticos.

**Justificativa:** Requisito direto do estudo de caso e ponto de atenção destacado pelo próprio grupo. No benchmark, essa é justamente a maior fraqueza dos 3 concorrentes analisados (Cataki, Descarte Rápido e Recycle Coach), nenhum funciona sem internet, o que torna essa funcionalidade um diferencial competitivo real.

### 6. Conteúdo educativo sobre compostagem doméstica

**Descrição:** Orienta o usuário sobre como compostar resíduos orgânicos em casa.

**Necessidade do usuário que atende:** Aproveitar o resíduo orgânico em vez de simplesmente descartá-lo, reduzindo o volume total de lixo gerado.

**Justificativa:** Segue a lógica de prioridade da PNRS (não geração e redução antes de descarte). A pesquisa mostrou que 71% das pessoas já sabem que resíduo orgânico pode virar composto, ou seja, é um público já sensibilizado que só precisa de orientação prática, não de convencimento.

### 7. Categorias de resíduos com código de cores

**Descrição:** Tela que organiza os resíduos por categoria (papel, plástico, vidro, orgânico, perigoso), usando o código de cores universal da reciclagem.

**Necessidade do usuário que atende:** Reconhecer visualmente e rapidamente a categoria de um resíduo, especialmente em situações de pouca atenção disponível.

**Justificativa:** É uma restrição obrigatória definida no estudo de caso, e atende diretamente ao público de escolas (persona Ana Beatriz), que precisa de uma interface visual e didática para uso em sala de aula.

### 8. Busca com reconhecimento de imagem (diferencial futuro)

**Descrição:** Permite tirar uma foto do resíduo para que o app sugira a categoria correta, sem precisar digitar o nome do item.

**Necessidade do usuário que atende:** Identificar resíduos quando o usuário não sabe nem o nome do item.

**Justificativa:** Inspirado no ponto forte do Recycle Coach no benchmark. Não é essencial para o MVP, mas soma valor real, principalmente para crianças (público escolar) e usuários com menor familiaridade com termos técnicos de reciclagem.

## 2.2. Requisitos Funcionais

### RF01 - Busca por classificação de resíduos
**Descrição:** O sistema deve permitir que o usuário digite o nome de um item a ser descartado e retorne a categoria correta e a orientação de descarte correspondente.

### RF02 - Mapa de pontos de coleta
**Descrição:** O sistema deve exibir, em um mapa, os ecopontos, cooperativas e pontos de coleta seletiva mais próximos do usuário, priorizando cooperativas de catadores.

### RF03 - Contador de impacto
**Descrição:** O sistema deve calcular e exibir, de forma acumulada e anônima, a quantidade de resíduos que o usuário já destinou corretamente à reciclagem.

### RF04 - Lembretes de coleta seletiva
**Descrição:** O sistema deve permitir que o usuário cadastre, consulte, edite e exclua lembretes referentes aos dias e horários da coleta seletiva de sua região.

### RF05 - Consulta offline
**Descrição:** O sistema deve permitir que o usuário consulte o guia de classificação de resíduos mesmo sem conexão com a internet.

### RF06 - Conteúdo educativo sobre compostagem
**Descrição:** O sistema deve disponibilizar orientações práticas sobre como realizar compostagem doméstica de resíduos orgânicos.

### RF07 - Categorias com código de cores
**Descrição:** O sistema deve organizar e exibir os resíduos por categoria (papel, plástico, vidro, orgânico, perigoso), utilizando o código de cores universal da reciclagem.

### RF08 - Busca por reconhecimento de imagem
**Descrição:** O sistema deve permitir que o usuário tire uma foto do resíduo para que o sistema sugira automaticamente a categoria correspondente.

## 2.4 CRUD

| Informação | C | R | U | D | Observações |
|---|:---:|:---:|:---:|:---:|---|
| Guia de classificação de resíduos (tipo → categoria → destino) | ✓ | ✓ | ✓ | ✕ | Criado e atualizado pela equipe de desenvolvimento (base de dados interna do app); o usuário apenas consulta. Não há exclusão porque o guia precisa estar sempre completo, remover um item quebraria a função principal do app. |
| Ecopontos e cooperativas de coleta | ✓ | ✓ | ✓ | ✓ | Cadastro inicial feito pela equipe a partir de fontes públicas; pode ser atualizado (mudança de endereço/horário) ou excluído (ponto desativado). O usuário só consulta, não edita. |
| Registro de reciclagem (para o contador de impacto) | ✓ | ✓ | ✕ | ✕ | Criado automaticamente a cada consulta/confirmação do usuário e consultado no contador de "quilos reciclados". Não é atualizável nem excluível porque o registro é anônimo e agregado localmente, não há vínculo com uma pessoa para permitir correção ou remoção individual, conforme o compromisso de privacidade do projeto. |
| Lembretes de coleta seletiva | ✓ | ✓ | ✓ | ✓ | O usuário cria o lembrete (dia/horário da coleta do bairro), pode consultá-lo, editá-lo (se o dia da coleta mudar) e excluí-lo quando não precisar mais. |
| Conteúdo educativo sobre compostagem | ✓ | ✓ | ✓ | ✕ | Criado e atualizado pela equipe (conteúdo editorial); o usuário apenas consulta. Sem exclusão para manter a base de orientações sempre completa. |
| Dados de identificação do usuário (nome, e-mail, localização exata, etc.) | ✕ | ✕ | ✕ | ✕ | Não se aplica. O app não coleta dados de identificação, conforme definido no compromisso do projeto. Isso também elimina a necessidade de cadastro/login, simplificando o fluxo de uso. |
