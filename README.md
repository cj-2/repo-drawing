# repo-draw

Desenha pixel art no gráfico de contribuições do GitHub criando commits com datas
retroativas. Cada desenho é uma grade de texto com o nível de cada dia do ano.

Criado por Carlos Júnior ([cj-2](https://github.com/cj-2)).

- Repositório original: https://github.com/cj-2/repo-draw
- Blog: https://cj-2.github.io

## Requisitos

- `git` configurado com `user.name` e `user.email`. O e-mail precisa estar
  cadastrado na sua conta do GitHub (Settings → Emails), senão os commits não
  contam no seu perfil.
- `bash` com `gawk`. No Windows, use o Git Bash (vem com o Git for Windows e já
  traz os dois).
- Opcional: [GitHub CLI](https://cli.github.com) (`gh`) para criar e apagar o
  repositório pelo terminal.

## A skill `desenho`

O repositório traz a skill [`desenho`](.agents/skills/desenho/SKILL.md) no formato
aberto de [Agent Skills](https://agentskills.io), que funciona em Claude Code,
Codex, Cursor, GitHub Copilot, Gemini CLI e outros agentes.

**Dentro deste repositório, não precisa instalar nada.** A skill fica em
`.agents/skills/desenho/`, pasta que Codex, Cursor, Copilot, Gemini CLI e outros
leem direto. O Claude Code só lê `.claude/skills/`, por isso
`.claude/skills/desenho/SKILL.md` é uma ponte que aponta para a skill em
`.agents/`. As regras e o script ficam num lugar só.

Para usar em qualquer outra pasta, instale globalmente (requer Node.js 22.20+):

```bash
npx skills add cj-2/repo-draw -g
```

O instalador pergunta em quais agentes instalar. Use `-a claude-code` (ou
`-a codex`, `-a cursor`...) para escolher direto. A skill leva junto o script
`gerar-commits.sh`.

## Criar um desenho com um agente

Numa pasta vazia (ou no seu repositório de desenhos), peça ao agente, por
exemplo:

```
/desenho 2021 uma baleia à esquerda e ondas na linha de sábado
```

No Claude Code e em outros agentes com comandos, `/desenho` chama a skill
direto; nos demais, basta pedir "faça um desenho no gráfico do GitHub: 2021,
uma baleia à esquerda...". O agente confere se o ano está livre, desenha a
grade, mostra a prévia com as cores reais e ajusta até você aprovar. Depois
cria os commits (pedindo confirmação antes). O `git push` fica com você.

## Grade de texto

Cada desenho é um arquivo `.txt`, por exemplo [jardim-2019.txt](jardim-2019.txt):

```
# ano: 2019
.0020200000004000000000303000000002000002220000000000
.0224220000444440000022303220000024200024442000000000
00022200444444444440220333022000002000002220000000000
0000300001141114110000003000000010300000030000020020.
0011300001111311110000444440000001301000031100223322.
0000311030222222203000044400000000310001130000003300.
1111311133122222133111144411111111311111131111113311.
```

- 7 linhas, de Domingo (1ª) a Sábado (7ª); cada caractere é uma semana.
- Cada célula é um nível de 0 a 4 (tabela abaixo). `.` marca dias fora do ano,
  no começo da primeira coluna e no fim da última.
- Linhas que começam com `#` são comentários.
- `# ano: AAAA` define o ano. Sem essa linha, o ano vem do nome do arquivo.
- `# niveis: 0 1 3 6 10` muda a quantidade de commits de cada nível (esse é o
  padrão).

| Nível | Cor | Commits |
|---|---|---|
| 0 | `#ebedf0` | 0 |
| 1 | `#9be9a8` | 1 |
| 2 | `#40c463` | 3 |
| 3 | `#30a14e` | 6 |
| 4 | `#216e39` | 10 |

Para fazer à mão, sem agente, rode o script da skill a partir da pasta deste
repositório (ou use o caminho onde a skill foi instalada). Gere a grade vazia
do ano, já com os `.` no lugar certo, e troque os `0` pelos níveis do desenho:

```bash
bash .agents/skills/desenho/gerar-commits.sh --modelo 2021 > baleia-2021.txt
```

## Criar os commits

```bash
bash .agents/skills/desenho/gerar-commits.sh baleia-2021.txt
```

- Valida a grade e diz onde está o erro, se faltar linha, sobrar coluna ou
  houver nível num dia que não existe no ano.
- Recusa o ano se o repositório já tiver commits nele (veja o aviso abaixo).
- Trabalha no repositório git da pasta atual e cria um, se ainda não existir.
- Para cada dia, cria a quantidade de commits do nível, ao meio-dia no fuso
  -03:00, para nenhum commit cair no dia vizinho no gráfico. Os commits alteram
  o arquivo `desenhos/<nome-da-grade>.log`.
- No fim, confere que a contagem por dia no git bate com a grade.

Algumas centenas de commits levam alguns minutos.

> **Um desenho por ano.** O GitHub conta commits por dia. Dois desenhos no mesmo
> ano somariam as contagens e se misturariam, por isso o script recusa um ano
> que já tem commits. Desenhos de anos diferentes podem ficar no mesmo
> repositório.

Commits normais feitos hoje caem na data de hoje e não alteram os desenhos.

## Enviar para o GitHub

Com o GitHub CLI:

```bash
gh repo create repo-draw --public --source=. --remote=origin --push
```

Ou crie um repositório vazio pelo site e envie:

```bash
git remote add origin https://github.com/<seu-usuario>/repo-draw.git
git push -u origin main
```

O GitHub só conta commits da branch padrão. Se o repositório for privado, ative
"Private contributions" no seu perfil para os desenhos aparecerem.

## Fazer uma nova sequência de desenhos

Para trocar, tirar ou refazer desenhos, não edite o histórico: **apague tudo e
recrie o repositório do zero.** Como o objetivo do repositório é só desenhar no
gráfico de contribuições, recriá-lo não perde nada. As grades `.txt` ficam na
pasta e podem ser usadas de novo.

1. **Apague o repositório no GitHub** (os desenhos antigos somem do perfil):

   ```bash
   gh repo delete <seu-usuario>/repo-draw --yes
   ```

   Ou pelo site: Settings do repositório → Danger Zone → Delete this repository.
   Pelo `gh`, pode ser preciso liberar a permissão antes com
   `gh auth refresh -s delete_repo`.

2. **Apague o git local e os registros dos desenhos antigos:**

   ```bash
   rm -rf .git desenhos pixel-art.log
   ```

3. **Gere os desenhos**, um por ano, com o `/desenho` ou a partir das grades:

   ```bash
   bash .agents/skills/desenho/gerar-commits.sh jardim-2019.txt
   bash .agents/skills/desenho/gerar-commits.sh pirata-2020.txt
   ```

4. **Commite os arquivos do projeto** (esse commit cai na data de hoje e não
   afeta os desenhos):

   ```bash
   git add README.md .agents .claude *.txt
   git commit -m "Adiciona skill, desenhos e documentação"
   ```

5. **Crie o repositório e envie**, como em [Enviar para o GitHub](#enviar-para-o-github).

## Reproduzir no seu perfil

Instale a skill (veja [A skill `desenho`](#a-skill-desenho)),
abra o seu agente numa pasta vazia, peça os desenhos com o `/desenho` e crie um
repositório novo para eles. Para mudar os desenhos depois, faça como em
[Fazer uma nova sequência de desenhos](#fazer-uma-nova-sequência-de-desenhos).
