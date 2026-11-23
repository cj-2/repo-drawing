# repo-drawing

Desenha pixel art no gráfico de contribuições do GitHub criando commits com datas
retroativas. Cada desenho é uma grade de texto com o nível de cada dia do ano.

Criado por Carlos Júnior ([cj-2](https://github.com/cj-2)).

- Repositório original: https://github.com/cj-2/repo-drawing
- Desenhos gerados a partir dele: https://github.com/cj-2/repo-drawing-result
- Blog: https://cj-2.github.io
- Como funciona por dentro: [docs/](docs/README.md)

> **Este repositório é a base e não tem desenhos.** Ele guarda o script, a
> skill, as grades de exemplo e a documentação. Tudo é feito daqui, mas os
> commits dos desenhos vão para um repositório ao lado, o **resultado**
> (`repo-drawing-result`).

| Repositório | Conteúdo | No GitHub |
|---|---|---|
| Base (este) | Código, skill, `exemplos/` e documentação, com commits normais | `repo-drawing` |
| Resultado | Só os commits dos desenhos e um README apontando para a base | `repo-drawing-result` |

## Requisitos

- `git` configurado com `user.name` e `user.email`. O e-mail precisa estar
  cadastrado na sua conta do GitHub (Settings → Emails), senão os commits não
  contam no seu perfil.
- `bash` com `gawk`. No Windows, use o Git Bash (vem com o Git for Windows e já
  traz os dois).
- Opcional: [GitHub CLI](https://cli.github.com) (`gh`) para criar e apagar o
  repositório pelo terminal.

## Pastas

```
repo-drawing/
├── .agents/skills/desenho/   # a skill e o script gerar-commits.sh
├── .claude/skills/desenho/   # ponte da skill para o Claude Code
├── exemplos/                 # grades de exemplo (commitadas)
├── desenhos-gerados/         # grades novas, ignoradas pelo git
└── docs/                     # como funciona por dentro
```

- **`exemplos/`** tem os desenhos que vêm com o projeto: `baleia-2018`,
  `jardim-2019` e `pirata-2020`.
- **`desenhos-gerados/`** recebe as grades que você cria. Ela está no
  `.gitignore`, então seus desenhos não entram no histórico da base. Para
  transformar um desenho em exemplo, mova a grade para `exemplos/` e commite.

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
npx skills add cj-2/repo-drawing -g
```

O instalador pergunta em quais agentes instalar. Use `-a claude-code` (ou
`-a codex`, `-a cursor`...) para escolher direto. A skill leva junto o script
`gerar-commits.sh`. Fora desta base, grades e commits ficam na pasta onde o
agente estiver.

## Criar um desenho com um agente

Nesta pasta, peça ao agente, por exemplo:

```
/desenho 2021 uma baleia à esquerda e ondas na linha de sábado
```

No Claude Code e em outros agentes com comandos, `/desenho` chama a skill
direto; nos demais, basta pedir "faça um desenho no gráfico do GitHub: 2021,
uma baleia à esquerda...". O agente confere se o ano está livre no resultado,
cria a grade em `desenhos-gerados/`, mostra a prévia com as cores reais e
ajusta até você aprovar. Depois cria os commits em `../repo-drawing-result`
(pedindo confirmação antes). O `git push` fica com você.

## Grade de texto

Cada desenho é um arquivo `.txt`, por exemplo
[exemplos/jardim-2019.txt](exemplos/jardim-2019.txt):

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

Para fazer à mão, sem agente, gere a grade vazia do ano, já com os `.` no lugar
certo, e troque os `0` pelos níveis do desenho:

```bash
mkdir -p desenhos-gerados
bash .agents/skills/desenho/gerar-commits.sh --modelo 2021 > desenhos-gerados/baleia-2021.txt
```

## Criar os commits

Daqui da base, com `--destino` apontando para o resultado:

```bash
bash .agents/skills/desenho/gerar-commits.sh --destino ../repo-drawing-result desenhos-gerados/baleia-2021.txt
```

- Valida a grade e diz onde está o erro, se faltar linha, sobrar coluna ou
  houver nível num dia que não existe no ano.
- Cria a pasta e o repositório do resultado, se ainda não existirem.
- Recusa o ano se o resultado já tiver commits nele (veja o aviso abaixo).
- Recusa gerar desenhos na própria base: sem `--destino`, rodando aqui, o
  script para e explica.
- Para cada dia, cria a quantidade de commits do nível, ao meio-dia no fuso
  -03:00, para nenhum commit cair no dia vizinho no gráfico. Os commits alteram
  o arquivo `desenhos/<nome-da-grade>.log` do resultado.
- No fim, confere que a contagem por dia no git bate com a grade.

Algumas centenas de commits levam alguns minutos.

> **Um desenho por ano.** O GitHub conta commits por dia. Dois desenhos no mesmo
> ano somariam as contagens e se misturariam, por isso o script recusa um ano
> que já tem commits. Desenhos de anos diferentes podem ficar no mesmo
> resultado.

### O README do resultado

Depois dos desenhos, o resultado ganha um `README.md` curto, que diz o que são
aqueles commits e aponta para esta base. Ele é commitado normalmente, com a data
do dia em que foi criado:

```bash
cd ../repo-drawing-result
git add README.md
git commit -m "Adiciona o README"
```

Esse commit cai no ano atual e soma 1 contribuição nesse dia, então o ano atual
não serve para desenho no resultado.

## Enviar para o GitHub

Na pasta do resultado, com o GitHub CLI:

```bash
gh repo create repo-drawing-result --public --source=. --remote=origin --push
```

Ou crie um repositório vazio pelo site e envie:

```bash
git remote add origin https://github.com/<seu-usuario>/repo-drawing-result.git
git push -u origin main
```

O GitHub só conta commits da branch padrão. Se o repositório for privado, ative
"Private contributions" no seu perfil para os desenhos aparecerem.

Para acrescentar o desenho de outro ano depois, gere-o com o mesmo `--destino`
e rode `git push` no resultado.

## Fazer uma nova sequência de desenhos

Para trocar, tirar ou refazer desenhos, não edite o histórico nem apague o git
de nenhuma pasta: **gere os desenhos numa pasta de resultado nova e troque o
repositório no GitHub.** A base nunca muda, e a pasta antiga do resultado fica
como estava até você decidir apagá-la.

1. **Gere tudo numa pasta nova**, a partir das grades que quiser:

   ```bash
   bash .agents/skills/desenho/gerar-commits.sh --destino ../repo-drawing-result-2 exemplos/jardim-2019.txt
   bash .agents/skills/desenho/gerar-commits.sh --destino ../repo-drawing-result-2 exemplos/pirata-2020.txt
   ```

   Depois, crie o README do resultado, como em
   [O README do resultado](#o-readme-do-resultado).

2. **Apague o repositório antigo dos desenhos no GitHub** (os desenhos antigos
   somem do perfil). Faça isso só depois de conferir o passo 1 ("OK" em todos),
   e confira o nome: é o resultado, nunca a base.

   ```bash
   gh repo delete <seu-usuario>/repo-drawing-result --yes
   ```

   Ou pelo site: Settings do repositório → Danger Zone → Delete this repository.
   Pelo `gh`, pode ser preciso liberar a permissão antes com
   `gh auth refresh -s delete_repo`.

3. **Envie a pasta nova com o nome de sempre:**

   ```bash
   cd ../repo-drawing-result-2
   gh repo create repo-drawing-result --public --source=. --remote=origin --push
   ```

Nunca faça rebase no resultado: um rebase recriaria os commits dos desenhos com
a data de hoje como data de commit.

## Reproduzir no seu perfil

Dois caminhos:

- **Só com a skill.** Instale a skill (veja [A skill `desenho`](#a-skill-desenho)),
  abra o seu agente numa pasta vazia, peça os desenhos com o `/desenho` e crie
  um repositório para eles.
- **A partir desta base.** Clone este repositório (ou faça um fork), peça os
  desenhos com o `/desenho` ou use os de `exemplos/`, e publique o resultado
  com o seu usuário. Seus desenhos ficam em `desenhos-gerados/`, fora do git.
