# 1. Visão geral

## A ideia em uma frase

O gráfico de contribuições do GitHub pinta cada dia conforme a quantidade de
commits daquele dia. Se você controla **quantos** commits existem em **cada
dia**, controla a cor de cada quadradinho e consegue desenhar.

O git permite escolher a data de um commit, e é isso que torna o desenho
possível: o projeto cria commits hoje, mas datados no passado.

## As três peças

| Peça | Onde | Papel |
|---|---|---|
| Grade de texto | `<nome>-<ano>.txt` | Descreve o desenho: um dígito de 0 a 4 por dia |
| Script | `.agents/skills/desenho/gerar-commits.sh` | Lê a grade, valida e cria os commits datados |
| Skill | `.agents/skills/desenho/SKILL.md` | Ensina um agente de IA a desenhar a grade, mostrar a prévia e chamar o script |

A separação é proposital:

- **A grade é o dado.** Texto puro, fácil de ler, versionar e reaproveitar. Uma
  grade pronta pode ser regerada em outro repositório a qualquer momento.
- **O script é determinístico.** Mesma grade, mesmos commits nas mesmas datas.
  Ele não precisa de agente: funciona direto no terminal.
- **A skill é a parte criativa e a conversa.** O agente cuida do que um script
  não sabe fazer bem (transformar "uma baleia nadando" em pixels, mostrar a
  prévia, ajustar até a pessoa aprovar) e delega o trabalho mecânico ao script.

Essa divisão vale para qualquer projeto com agentes: o modelo decide e conversa,
o código executa e confere.

## O caminho de um desenho

```mermaid
flowchart LR
    A["Pedido<br>/desenho 2021 uma baleia"] --> B["Agente lê<br>SKILL.md"]
    B --> C["--modelo 2021<br>grade vazia"]
    C --> D["Agente preenche<br>os níveis"]
    D --> E["Prévia<br>com as cores reais"]
    E -->|ajustes| D
    E -->|aprovado| F["gerar-commits.sh<br>baleia-2021.txt"]
    F --> G["Commits datados<br>no repositório local"]
    G -->|git push| H["Perfil do GitHub"]
```

1. **Conferir o ano.** Só cabe um desenho por ano no mesmo repositório, porque
   o GitHub soma os commits de cada dia (detalhes no
   [capítulo 2](02-grafico-de-contribuicoes.md)).
2. **Gerar a grade vazia.** `gerar-commits.sh --modelo <ano>` imprime 7 linhas
   com `0` nos dias do ano e `.` nos dias que não existem. É o "papel
   quadriculado" do ano certo.
3. **Desenhar.** Trocar os `0` pelos níveis do desenho.
4. **Prévia.** Ver o desenho com as cores reais antes de criar qualquer commit.
   Desfazer commits dá trabalho; editar texto, não.
5. **Gerar os commits.** O script cria N commits por dia, conforme o nível, e
   no fim confere a contagem no próprio git.
6. **Enviar.** `git push`. O desenho aparece quando o GitHub processa os
   commits.

## Por que apagar e recriar em vez de editar

Para trocar um desenho, o projeto recomenda apagar o repositório (no GitHub e o
`.git` local) e gerar tudo de novo a partir das grades. Reescrever o histórico
com `git rebase` ou `git filter-repo` também funcionaria, mas:

- o repositório dos desenhos não tem nada além dos commits gerados, então não
  há o que preservar;
- gerar de novo a partir das grades é previsível e conferido pelo próprio
  script;
- um `push --force` com centenas de commits reescritos é mais fácil de errar
  do que apagar e recriar.

As grades ficam fora desse repositório (aqui, neste repositório de
documentação), então apagar o `.git` dos desenhos não perde nada.

## Próximo passo

Entenda o que o GitHub realmente conta: [2. O gráfico de contribuições](02-grafico-de-contribuicoes.md).
