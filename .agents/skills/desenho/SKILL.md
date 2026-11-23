---
name: desenho
description: Cria uma pixel art no gráfico de contribuições do GitHub — desenha a grade do ano em texto, mostra a prévia, ajusta até o usuário aprovar e cria os commits com datas retroativas. Use quando o usuário pedir um desenho no gráfico de contribuições, informando ano e descrição (ex. "desenho 2021 uma baleia à esquerda"). Use também para recriar os commits a partir de grades `.txt` já existentes (ex. depois de recriar o repositório).
---

<!-- Não use cifrão seguido de número neste arquivo: alguns agentes trocam por argumentos do comando. -->

# Desenho no gráfico de contribuições do GitHub

O pedido do usuário traz o ano e a descrição do desenho. Se faltar algum dos
dois, pergunte antes de começar. Responda no idioma do usuário.

Se o usuário pedir para criar os commits a partir de grades que já existem
(por exemplo, depois de recriar o repositório), não desenhe nada: siga a seção
"Recriar a partir de grades existentes", no fim deste arquivo.

O script `gerar-commits.sh` fica na mesma pasta deste `SKILL.md`; nos comandos
abaixo, `<skill>` é o caminho dessa pasta. Os desenhos ficam no repositório git
da pasta atual: se a pasta atual não for o repositório de desenhos do usuário
(ou uma pasta vazia para criá-lo), pergunte onde trabalhar.

Requisitos: `git`, `bash` e `gawk` (no Windows, o Git Bash traz os três).

## 1. Conferir o ano

O GitHub soma commits do mesmo dia, então só pode haver um desenho por ano no
repositório:

```bash
git log --format=%ad --date=format:%Y 2>/dev/null | grep -c "^<ano>$"
ls *-<ano>.txt 2>/dev/null
```

Se já houver commits nesse ano, avise e pare: a saída é escolher outro ano ou
recriar o repositório do zero (veja "Recriar a partir de grades existentes").
O script também recusa um ano com commits.

Se houver uma grade desse ano mas nenhum commit, ela é um desenho ainda não
gerado: mostre a prévia dela e pergunte se o usuário quer usá-la (vá para o
passo 3), substituí-la por um desenho novo ou escolher outro ano. Não
sobrescreva a grade sem o ok.

## 2. Desenhar a grade

Crie a grade vazia do ano com o nome do desenho (minúsculas, sem espaços):

```bash
bash <skill>/gerar-commits.sh --modelo <ano> > <nome>-<ano>.txt
```

A grade tem 7 linhas (Domingo a Sábado, de cima para baixo) e uma coluna por
semana (53 ou 54). Cada célula é um nível de 0 a 4; as células com `.` são dias
fora do ano e devem continuar `.`. Edite só os dígitos, mantendo as linhas de
comentário e o comprimento de cada linha. Acrescente um comentário com uma
frase descrevendo o desenho.

| Nível | Cor | Commits |
|---|---|---|
| 0 | `#ebedf0` | 0 |
| 1 | `#9be9a8` | 1 |
| 2 | `#40c463` | 3 |
| 3 | `#30a14e` | 6 |
| 4 | `#216e39` | 10 |

Regras de desenho:

- Formas simples e blocos de uma cor só. Com 7 linhas de altura, poucos
  detalhes funcionam melhor.
- Separe as partes com contraste (claro ao lado de escuro), não com pixels
  soltos.
- Respeite a posição que o usuário descreveu (esquerda, meio, direita, linha de
  sábado etc.). A coluna 1 é o começo de janeiro e a última é o fim de dezembro;
  cada mês ocupa cerca de 4 a 5 colunas.
- Só desenhos originais: nada de personagens, logos ou símbolos de marcas ou
  obras conhecidas. Se o pedido for um deles, explique e proponha algo original.

## 3. Prévia e ajustes

Mostre a grade inteira com as cores reais da tabela acima: se o agente tiver
uma ferramenta de visualização (SVG/HTML inline ou artifact), desenhe 7 linhas ×
colunas de quadrados arredondados com o nome dos meses em cima; sem ela, mostre
a grade em texto trocando os níveis por `·░▒▓█`. Se houver personagens ou
objetos pequenos, mostre também uma versão ampliada deles.

Espere o usuário aprovar ou pedir ajustes. A cada pedido, mude de verdade a
grade e mostre a nova prévia. Se algo não estiver funcionando, sugira
simplificar, aumentar ou trocar as cores das partes.

## 4. Criar os commits

Depois da aprovação, informe quantos commits serão criados e pergunte se pode
seguir.

Se a pasta atual for a base do projeto (tem a skill em `.agents/` e nenhum
commit de desenho), não gere os commits ali: commite a grade (com o ok do
usuário) e gere num clone, como no passo 2 de "Recriar a partir de grades
existentes".

Com o ok:

```bash
bash <skill>/gerar-commits.sh <nome>-<ano>.txt
```

O script valida a grade, cria os commits e confere sozinho a contagem por dia
(termina com "OK"). Algumas centenas de commits levam alguns minutos: rode em
segundo plano se o agente permitir. Não faça `git push` sem o usuário pedir.

## 5. Lembretes finais

- O GitHub calcula as cores em relação aos dias do próprio usuário. Se os tons
  ficarem parecidos no perfil, afaste os valores com uma linha
  `# niveis: 0 1 5 10 20` na grade e gere o desenho de novo num clone novo
  (veja "Recriar a partir de grades existentes").
- Os commits usam o `user.email` do git, que precisa estar cadastrado na conta
  do GitHub.
- Para aparecer no perfil: `git push`, ou criar o repositório no GitHub e
  enviar (ex. `gh repo create <nome> --public --source=. --push`). O GitHub só
  conta commits da branch padrão.

## Recriar a partir de grades existentes

Use quando o usuário já tem as grades `<nome>-<ano>.txt` e quer só gerar os
commits: refazer a sequência de desenhos, publicar num repositório novo ou
gerar um ano que ainda não foi gerado.

Nunca apague o `.git` da pasta do usuário para recriar. A pasta onde ficam as
grades é a base (o repositório de referência, sem desenhos); os desenhos são
gerados num clone novo, e o repositório antigo dos desenhos no GitHub é trocado
pelo novo.

1. Liste as grades (`ls *-[0-9][0-9][0-9][0-9].txt`) e confira se há no máximo
   uma por ano. Com duas do mesmo ano, pergunte qual usar.
2. Escolha onde gerar:
   - **Só acrescentar um ano livre** (nenhum commit nesse ano, conferido como
     no passo 1) num repositório de desenhos que já existe: gere ali mesmo.
   - **Refazer a sequência**, ou a pasta atual é a base do projeto (tem a skill
     em `.agents/` e nenhum commit de desenho): gere num clone novo. Confira com
     `git status` se as grades estão commitadas, porque o clone só leva o que
     está no git; se não estiverem, mostre quais e peça para commitar. Depois:

     ```bash
     git clone . ../<pasta-nova>
     ```

     Sugira um nome para `<pasta-nova>` (ex. `repo-drawing-result`, o mesmo
     nome do repositório dos desenhos no GitHub), confira que ela ainda não
     existe e trabalhe dentro dela a partir daqui. Se a pasta das
     grades não for um repositório git, crie uma pasta nova vazia e copie as
     grades para ela.
   Grades de anos que já têm commits no repositório escolhido ficam de fora:
   avise quais são. O ano dos commits normais do projeto (os que vieram no
   clone) também fica de fora, porque o script o recusa.
3. A prévia é opcional: mostre se o usuário pedir ou se a grade parecer
   estranha. Some os commits de todas as grades (nível 1 = 1, 2 = 3, 3 = 6,
   4 = 10, ou os valores de `# niveis:` da grade), informe o total por ano e
   peça o ok.
4. Rode o script para cada grade, uma de cada vez e em segundo plano se der:

   ```bash
   bash <skill>/gerar-commits.sh <nome>-<ano>.txt
   ```

   Cada execução precisa terminar com "OK". Se uma falhar, pare e mostre o
   erro antes de seguir para a próxima.
5. Para publicar uma sequência refeita, o usuário apaga o repositório antigo
   dos desenhos no GitHub (pelo site ou com
   `gh repo delete <usuario>/<repo-dos-desenhos> --yes`). Não apague você: peça
   que ele faça, só depois que todos os desenhos tiverem dado "OK", e lembre de
   conferir o nome: o repositório de referência (a base, sem desenhos) nunca é
   apagado nem recebe os commits dos desenhos.
   No clone, tire o remoto que aponta para a pasta base e envie para o
   repositório novo, mas só quando o usuário pedir:

   ```bash
   git remote remove origin
   gh repo create <repo-dos-desenhos> --public --source=. --remote=origin --push
   ```

6. Para levar ao clone uma grade nova da base depois, use
   `git pull --no-rebase <pasta-base> main`. Nunca faça rebase de um
   repositório com desenhos: os commits seriam recriados com a data de hoje.
