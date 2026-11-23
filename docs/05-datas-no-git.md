# 5. Datas no git

O projeto inteiro depende de um detalhe do git: a data de um commit é só um
campo que quem faz o commit preenche. Este capítulo mostra onde ela fica e como
controlá-la.

## Todo commit tem duas datas

Um commit é um objeto de texto. Veja um gerado pelo script com
`git cat-file -p <hash>`:

```
tree 4b825dc6...
parent 9f1e2c3a...
author Fulano <fulano@exemplo.com> 1562252460 -0300
committer Fulano <fulano@exemplo.com> 1562252460 -0300

pixel 2019-07-04 (1/10)
```

- **`author`**: quem escreveu a mudança e quando.
- **`committer`**: quem gravou o commit no repositório e quando.

Cada data é um **timestamp Unix** (segundos desde 1970-01-01 em UTC) mais o
**fuso** de quem fez o commit. `1562252460` é 4/7/2019 às 15:01 em UTC; com
`-0300`, é exibido como 12:01 no horário de Brasília.

Normalmente as duas datas são iguais. Elas se separam quando o histórico é
reescrito: um `git rebase` ou `git commit --amend` mantém a data de autor e põe
a hora atual como data de commit. Um `git cherry-pick` faz o mesmo.

Para ver as duas:

```bash
git log --format=fuller -1
```

## Como escolher a data

| Jeito | Data de autor | Data de commit |
|---|---|---|
| `git commit --date="2019-07-04T12:01:00-03:00"` | escolhida | hora atual |
| `GIT_AUTHOR_DATE=...` | escolhida | hora atual |
| `GIT_COMMITTER_DATE=...` | hora atual | escolhida |
| As duas variáveis juntas | escolhida | escolhida |

O script usa **as duas variáveis**. Assim o commit fica com uma data só, sem
depender de qual das duas o GitHub ou outra ferramenta resolver mostrar.

O formato usado é ISO 8601 com fuso explícito:

```
2019-07-04T12:01:00-03:00
```

Sem o fuso, o git usaria o fuso da máquina, e o mesmo script geraria commits
diferentes em computadores diferentes. Com o fuso fixo, o resultado é sempre o
mesmo.

## Por que meio-dia

O dia de um commit depende do fuso em que você olha:

| Horário no commit | Em UTC | Dia em UTC |
|---|---|---|
| 04/07 00:30 -03:00 | 04/07 03:30 | 04/07 |
| 04/07 12:01 -03:00 | 04/07 15:01 | 04/07 |
| 04/07 23:30 -03:00 | 05/07 02:30 | **05/07** |

Um commit perto da meia-noite pode mudar de dia conforme a regra de quem o
exibe. Ao meio-dia de -03:00 sobra uma margem grande para os dois lados: o
commit cai no mesmo dia no fuso do commit, em UTC e em qualquer fuso de -12:00
a +08:00.

## Como conferir

O dia de cada commit, no fuso gravado nele:

```bash
git log --format=%ad --date=format:%Y-%m-%d | sort | uniq -c
```

O mesmo, convertido para o fuso da sua máquina:

```bash
git log --format=%ad --date=format-local:%Y-%m-%d | sort | uniq -c
```

`format:` usa o fuso de cada commit; `format-local:` converte para o fuso
local. A conferência do script usa `format:`, porque é o fuso com que os
commits foram criados.

## O que a data não muda

A data é só um campo informativo. O git não exige que a data de um commit seja
maior que a do commit anterior, e não usa as datas para nada essencial: a
ordem real do histórico vem dos ponteiros `parent`. Por isso é possível criar
hoje um commit datado de 2019, logo depois de um datado de 2020.

O efeito colateral também é importante: **a data de um commit não prova
nada.** Qualquer pessoa pode datar commits no passado. Num processo de revisão,
o que tem valor é quando o commit chegou ao servidor (o push, o pull request),
não a data escrita nele.

## Próximo passo

Veja como o agente entra na história: [6. A skill e os agentes](06-skill-e-agentes.md).
