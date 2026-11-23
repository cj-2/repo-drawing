---
name: desenho
description: Cria uma pixel art no gráfico de contribuições do GitHub — desenha a grade do ano em texto, mostra a prévia, ajusta até o usuário aprovar e cria os commits com datas retroativas. Use quando o usuário pedir um desenho no gráfico de contribuições, informando ano e descrição (ex. "/desenho 2021 uma baleia à esquerda").
metadata:
  internal: true
---

Ponte para o Claude Code, que só lê skills em `.claude/skills/`. A skill de
verdade fica em `.agents/skills/desenho/`, junto com o script.

Pedido do usuário: $ARGUMENTS

Leia `.agents/skills/desenho/SKILL.md` (na raiz deste repositório) e siga
exatamente essas instruções, usando `.agents/skills/desenho` como `<skill>`.
