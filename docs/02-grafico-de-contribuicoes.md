# 2. O gráfico de contribuições

Para desenhar no gráfico, primeiro é preciso entender o que ele mostra. O
resumo: **um quadradinho por dia, colorido pela quantidade de contribuições do
dia, comparada com os outros dias da própria pessoa.**

## A forma do gráfico

- Cada **coluna** é uma semana, de domingo a sábado.
- Cada **linha** é um dia da semana: a 1ª é domingo e a 7ª é sábado.
- O ano começa no dia da semana em que cai 1º de janeiro. Por isso a primeira
  coluna costuma ter dias "vazios" no topo e a última, dias vazios embaixo.
- Um ano tem 53 colunas na maioria das vezes, e 54 quando é bissexto e começa
  num sábado (2000, 2028).

É exatamente esse layout que a grade de texto reproduz (veja o
[capítulo 3](03-grade-de-texto.md)).

## O que conta como contribuição

Para um commit pintar um quadradinho, ele precisa:

- ter como **e-mail de autor** um endereço cadastrado e verificado na sua conta
  do GitHub (Settings → Emails). É o `user.email` do git no momento do commit;
- estar na **branch padrão** do repositório (ou na `gh-pages`). Commits em
  outras branches não contam;
- estar num repositório que **não é fork**. Fork só conta em casos especiais.

Se o repositório for privado, os quadradinhos só aparecem para os outros se
"Private contributions" estiver ativado no perfil.

A referência oficial é a página
[Why are my contributions not showing up on my profile?](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/why-are-my-contributions-not-showing-up-on-my-profile).

## Em que dia o commit cai

O GitHub agrupa as contribuições por dia, e a documentação diz que usa UTC
para isso. Um commit às 23h em São Paulo (-03:00) já é 02h do dia seguinte em
UTC e poderia cair no quadradinho errado.

O script resolve isso datando todos os commits **ao meio-dia no fuso -03:00**,
que é 15h em UTC. Esse horário fica no mesmo dia tanto no fuso do commit quanto
em UTC, então o dia não muda seja qual for a regra usada. O
[capítulo 5](05-datas-no-git.md) explica as datas do git em detalhe.

## As cores são relativas

O gráfico usa cinco tons:

| Nível | Cor | Commits por dia na grade |
|---|---|---|
| 0 | `#ebedf0` | 0 |
| 1 | `#9be9a8` | 1 |
| 2 | `#40c463` | 3 |
| 3 | `#30a14e` | 6 |
| 4 | `#216e39` | 10 |

O tom **não** é fixo por número de commits. O GitHub distribui os tons de
acordo com as contribuições da própria pessoa: o que é "muito" para um perfil
com poucos commits é "pouco" para um perfil muito ativo. Os valores 1, 3, 6 e
10 funcionam bem num perfil comum porque são bem espaçados.

Se no seu perfil dois níveis ficarem com o mesmo tom, afaste os valores com uma
linha na grade, por exemplo `# niveis: 0 1 5 10 20`, e gere o desenho de novo
numa pasta de resultado nova (veja o README). Commits normais que você faz em
outros projetos também entram nessa conta, mas caem na data de hoje e não
alteram os dias desenhados.

## Por que só um desenho por ano

O gráfico mostra **a soma** das contribuições de cada dia, vindas de todos os
repositórios. Dois desenhos no mesmo ano, no mesmo repositório ou em
repositórios diferentes, somariam os commits dos dias em comum e virariam uma
mancha. O script recusa um ano que já tem commits no repositório atual, mas não
tem como ver os seus outros repositórios: essa conferência fica com você.

## Quando aparece

Depois do `git push`, o GitHub precisa processar os commits. Normalmente leva
alguns minutos; a documentação fala em até 24 horas.

## Próximo passo

Veja como o desenho vira texto: [3. A grade de texto](03-grade-de-texto.md).
