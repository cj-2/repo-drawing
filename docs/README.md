# Documentação do repo-drawing

Esta pasta explica como o projeto funciona por dentro. O [README da raiz](../README.md)
diz **como usar**; aqui o foco é **por que funciona assim**, para quem é da área e
quer aprender com o que acontece no repositório: git, shell, `gawk`, datas e
agentes de IA guiados por skills.

## Por onde ler

| # | Documento | O que você aprende |
|---|---|---|
| 1 | [Visão geral](01-visao-geral.md) | As peças do projeto e o caminho de um desenho até o perfil |
| 2 | [O gráfico de contribuições](02-grafico-de-contribuicoes.md) | O que o GitHub conta, em que dia e com que cor |
| 3 | [A grade de texto](03-grade-de-texto.md) | O formato `.txt` e a conta que liga linha e coluna a uma data |
| 4 | [O script `gerar-commits.sh`](04-script-gerar-commits.md) | Leitura guiada do script, bloco a bloco |
| 5 | [Datas no git](05-datas-no-git.md) | Data de autor e de commit, fuso e por que o meio-dia |
| 6 | [A skill e os agentes](06-skill-e-agentes.md) | Como uma skill orienta um agente e por que existe a ponte em `.claude/` |
| 7 | [Problemas comuns](07-problemas-comuns.md) | Sintomas, causas e o que fazer |

Quem tem pouco tempo pode ler só o 1 e o 3. Quem quer mexer no script deve ler
o 4 e o 5 antes.

## Mapa do repositório

```
repo-drawing/
├── .agents/skills/desenho/
│   ├── SKILL.md            # instruções para o agente (formato Agent Skills)
│   └── gerar-commits.sh    # o script que faz o trabalho de verdade
├── .claude/skills/desenho/
│   └── SKILL.md            # ponte: o Claude Code só lê .claude/skills/
├── exemplos/               # grades de exemplo, um desenho por ano (commitadas)
│   ├── baleia-2018.txt
│   ├── jardim-2019.txt
│   └── pirata-2020.txt
├── desenhos-gerados/       # grades novas, ignoradas pelo git (.gitignore)
├── docs/                   # esta documentação
└── README.md               # guia de uso
```

## Esta pasta é a base, não o repositório dos desenhos

Esta pasta é a base do projeto, publicada no GitHub como `cj-2/repo-drawing`.
Ela guarda o código, as grades de exemplo e a documentação, com commits
normais, e não tem desenhos. Tudo é feito daqui, mas os commits dos desenhos
vão para um repositório ao lado, o **resultado** (`repo-drawing-result`), com a
opção `--destino` do script (veja
[Base e resultado](01-visao-geral.md#base-e-resultado-onde-ficam-os-desenhos)).

O próprio script protege a base: rodando aqui sem `--destino`, ou com um
destino dentro desta pasta, ele recusa e explica. Gerar a grade vazia com
`--modelo` é seguro em qualquer lugar, porque não toca no git.
