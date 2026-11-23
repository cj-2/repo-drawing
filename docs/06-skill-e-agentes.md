# 6. A skill e os agentes

O script faz o trabalho mecânico. A parte de transformar "uma baleia nadando"
em pixels, mostrar a prévia e ajustar fica com um agente de IA (Claude Code,
Codex, Cursor, Copilot, Gemini CLI...). O que diz ao agente como fazer isso é a
**skill**.

## O que é uma skill

Uma skill é uma pasta com um arquivo `SKILL.md` e, se precisar, arquivos de
apoio (aqui, o `gerar-commits.sh`). O formato é o aberto de
[Agent Skills](https://agentskills.io), lido por vários agentes.

O `SKILL.md` tem duas partes:

```markdown
---
name: desenho
description: Cria uma pixel art no gráfico de contribuições do GitHub — ...
  Use quando o usuário pedir um desenho no gráfico de contribuições ...
---

# Desenho no gráfico de contribuições do GitHub
(instruções passo a passo)
```

- **O cabeçalho (frontmatter)** tem o nome e a descrição. O agente vê a
  descrição de todas as skills disponíveis e decide, por ela, quando usar
  cada uma. Por isso a descrição diz **o que** a skill faz e **quando** usar.
- **O corpo** só é lido quando a skill é usada. São as instruções detalhadas.

Essa carga em duas etapas permite ter muitas skills instaladas sem encher o
contexto do agente: ele carrega só o que precisa, quando precisa.

## O que a skill `desenho` ensina

Vale ler o [SKILL.md](../.agents/skills/desenho/SKILL.md) inteiro. As escolhas
de projeto mais importantes:

1. **Conferir antes de agir.** O primeiro passo é ver se o ano está livre. O
   script também confere, mas avisar antes poupa trabalho perdido.
2. **Usar o script para o que é mecânico.** O agente não calcula datas nem
   cria commits à mão: ele chama `--modelo` para a grade vazia e o script para
   os commits. O modelo erra conta de calendário com facilidade; o código não.
3. **Prévia antes de qualquer efeito.** O agente mostra o desenho com as cores
   reais e espera a aprovação. Editar texto é barato; desfazer centenas de
   commits, não.
4. **Confirmar o que tem efeito.** Antes de criar os commits, o agente diz
   quantos serão e pede o ok. E nunca faz `git push` sem a pessoa pedir.
5. **Regras de desenho explícitas.** Formas simples, contraste entre as partes,
   respeitar a posição pedida. Sem isso, cada execução sairia de um jeito.
6. **Limites de conteúdo.** Só desenhos originais: nada de personagens ou
   marcas conhecidas.
7. **Caminho alternativo.** A seção "Recriar a partir de grades existentes"
   cobre quem já tem as grades e quer só os commits. Sem ela, o agente seguia
   o passo 1, achava a grade do ano e parava.
8. **Lugar certo para cada coisa.** Na base, a skill põe grades novas em
   `desenhos-gerados/` e os commits no resultado, com `--destino`. Fora da
   base, usa a pasta atual. O script reforça a regra recusando a base.

O item 7 foi acrescentado depois de um teste: a pergunta "a skill consegue
recriar a partir dos arquivos?" mostrou que o script conseguia, mas as
instruções levavam o agente a parar. Skills se testam como código: com pedidos
reais, olhando onde o agente trava.

## Por que existem dois `SKILL.md`

```
.agents/skills/desenho/SKILL.md    ← a skill de verdade, com o script
.claude/skills/desenho/SKILL.md    ← ponte para o Claude Code
```

Codex, Cursor, Copilot, Gemini CLI e outros leem skills em `.agents/skills/`.
O Claude Code lê só `.claude/skills/`. Para não manter duas cópias das regras,
a versão em `.claude/` é uma ponte curta:

```markdown
Pedido do usuário: $ARGUMENTS

Leia `.agents/skills/desenho/SKILL.md` (na raiz deste repositório) e siga
exatamente essas instruções, usando `.agents/skills/desenho` como `<skill>`.
```

- `$ARGUMENTS` é trocado pelo texto que vem depois do comando. Em
  `/desenho 2021 uma baleia`, vira `2021 uma baleia`.
- `metadata: internal: true` no cabeçalho marca a ponte como interna, para
  ferramentas de instalação não a oferecerem como uma skill separada.

Um efeito dessa troca de argumentos explica o comentário no topo da skill
principal: *"Não use cifrão seguido de número neste arquivo"*. Alguns agentes
trocam `$1`, `$2`... pelos argumentos do comando, o que estragaria exemplos
de shell escritos dentro do `SKILL.md`.

## A skill dentro e fora do repositório

- **Dentro deste repositório**, não é preciso instalar nada: os agentes acham a
  skill em `.agents/` ou `.claude/`.
- **Em qualquer outra pasta**, a skill é instalada globalmente com
  `npx skills add cj-2/repo-drawing -g` (veja o [README](../README.md#a-skill-desenho)).
  O script vai junto, e a skill o chama pelo caminho da própria pasta
  (`<skill>/gerar-commits.sh`). Por isso o `SKILL.md` nunca fixa um caminho
  absoluto.

## O agente não decide tudo

Algumas ações ficam com a pessoa, de propósito:

- **Publicar.** Criar um repositório público e enviar os commits expõe o
  e-mail dos commits e o histórico. Agentes em modo automático podem bloquear
  essa ação e pedir que a pessoa rode o comando. Foi o que aconteceu na
  primeira publicação deste projeto: o `gh repo create --public --push` foi
  barrado, e o comando foi rodado à mão.
- **Apagar.** Apagar o repositório antigo no GitHub não tem volta. Por isso a
  skill nunca apaga nada: para refazer os desenhos, ela gera tudo numa pasta
  de resultado nova e pede que a pessoa apague o repositório antigo, só depois
  que todos os desenhos novos deram "OK". Nada local é apagado.

Uma boa skill deixa claro quais passos o agente faz sozinho e quais precisam de
um "sim".

## Próximo passo

Quando algo dá errado: [7. Problemas comuns](07-problemas-comuns.md).
