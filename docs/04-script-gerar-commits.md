# 4. O script `gerar-commits.sh`

Leitura guiada do [script](../.agents/skills/desenho/gerar-commits.sh). Os
números de linha se referem à versão atual do arquivo. Vale ler com o script
aberto ao lado.

Ele tem dois modos:

```bash
bash gerar-commits.sh --modelo 2021 > desenhos-gerados/baleia-2021.txt     # imprime a grade vazia
bash gerar-commits.sh --destino ../repo-drawing-result desenhos-gerados/baleia-2021.txt   # cria os commits
```

Sem `--destino`, os commits vão para o repositório da pasta atual, o que serve
para quem usa a skill fora desta base.

## Visão em blocos

| Linhas | Bloco | O que faz |
|---|---|---|
| 22–24 | Preparação | Modo estrito do bash e conferência do `gawk` |
| 26–34 | `AWK_COMUM` | Funções de calendário usadas pelos dois modos |
| 36–50 | `--modelo` | Imprime a grade vazia do ano |
| 52–61 | Argumentos | Lê `--destino` e guarda o caminho absoluto da grade |
| 63–108 | Leitura da grade | Valida a grade e transforma em "data → commits" |
| 111–121 | Destino e trava | Vai para a pasta do resultado e recusa a base |
| 123–133 | Repositório | Cria o repositório se preciso e recusa ano ocupado |
| 135–150 | Commits | Cria N commits por dia com a data escolhida |
| 152–160 | Conferência | Compara a contagem no git com a grade |

## Preparação (linhas 22–24)

```bash
set -euo pipefail
```

- `-e`: para no primeiro comando que falhar;
- `-u`: trata variável não definida como erro, em vez de string vazia;
- `-o pipefail`: um pipeline falha se **qualquer** etapa falhar, não só a
  última.

É o "modo estrito" que todo script bash que mexe em coisas importantes deveria
usar. O preço aparece mais adiante: comandos que falham de propósito precisam
de `|| true`.

Em seguida o script confere se o `gawk` existe. Ele precisa da versão GNU do
awk por três extensões: `strftime`, `mktime` e o terceiro argumento de
`match`, que guarda os grupos capturados num array.

## Funções de calendário (linhas 26–34)

```awk
function inicio(ano) {
  dow0 = strftime("%w", mktime(ano " 1 1 12 0 0")) + 0
  ndias = (ano % 4 == 0 && (ano % 100 != 0 || ano % 400 == 0)) ? 366 : 365
  ncol = int((ndias - 1 + dow0) / 7) + 1
}
function indice(r, c) { return (c - 1) * 7 + (r - 1) - dow0 }
```

- `mktime("2019 1 1 12 0 0")` transforma "ano mês dia hora minuto segundo" em
  timestamp Unix; `strftime("%w", ...)` devolve o dia da semana (0 = domingo).
  Usar meio-dia evita surpresas com horário de verão perto da meia-noite.
- `ndias` é a regra do ano bissexto: divisível por 4, exceto os seculares que
  não são divisíveis por 400 (1900 não é bissexto, 2000 é).
- `ncol` e `indice` são as fórmulas explicadas no
  [capítulo 3](03-grade-de-texto.md#a-conta-que-liga-a-grade-às-datas).

As funções ficam numa variável de shell (`AWK_COMUM`) e são coladas no começo
de cada programa awk. É um jeito simples de compartilhar código entre dois
programas awk sem criar um arquivo à parte.

## Modo `--modelo` (linhas 36–50)

Percorre 7 linhas × `ncol` colunas e imprime `0` quando `indice` cai dentro do
ano e `.` quando não. Como só escreve na saída padrão, é seguro rodar em
qualquer pasta.

## Argumentos (linhas 52–61)

```bash
if [ "${1:-}" = "--destino" ]; then
  DESTINO="${2:?$USO}"
  shift 2
fi
ARG="${1:?$USO}"
GRADE="$(cd "$(dirname "$ARG")" && pwd)/$(basename "$ARG")"
```

- `${2:?$USO}` para o script com a mensagem de uso se o valor faltar. É a
  forma curta de validar argumentos obrigatórios no bash.
- `shift 2` descarta `--destino` e a pasta, e o resto segue como se a opção
  não existisse.
- A grade vira um **caminho absoluto** logo aqui. Mais adiante o script muda
  de pasta para o destino; um caminho relativo como
  `desenhos-gerados/x.txt` deixaria de apontar para o arquivo.

## Leitura e validação da grade (linhas 63–108)

A grade passa por `tr -d '\r'`, para aceitar arquivos salvos no Windows, e
depois por um programa awk que:

1. **Lê os comentários.** `match($0, /ano:[[:space:]]*([0-9]{4})/, m)` captura
   o ano em `m[1]`. O mesmo vale para `# niveis:`, que precisa de 5 números.
2. **Guarda as 7 primeiras linhas de células** e conta quantas vieram.
3. **No `END`, valida tudo.** São 7 linhas? O ano veio do comentário ou do
   nome do arquivo? Cada linha cabe em `ncol` colunas? Cada dia do ano tem um
   dígito de 0 a 4? Os dias fora do ano estão com `.`? Cada erro diz a linha
   (pelo nome do dia) e a coluna.
4. **Imprime o resultado** como texto simples: primeiro `ano AAAA` e depois uma
   linha `AAAA-MM-DD N` para cada dia com commits.

Um detalhe elegante está na geração das datas:

```awk
strftime("%Y-%m-%d", mktime(ano " 1 " (i + 1) " 12 0 0"))
```

Em vez de calcular mês e dia, o script pede "dia `i + 1` de janeiro". O
`mktime` normaliza valores fora do intervalo, então "32 de janeiro" vira 1º de
fevereiro, e "185 de janeiro" vira 4 de julho. A biblioteca de datas resolve
meses com tamanhos diferentes e anos bissextos.

Outro detalhe: `erro()` marca `falhou = 1` e chama `exit 1`. No awk, `exit`
dentro de uma regra ainda executa o bloco `END`, por isso o `END` começa com
`if (falhou) exit 1`, para não continuar validando uma grade que já falhou.

As linhas 107–108 separam a primeira linha (o ano) do resto (os dias). Passar
dados entre etapas como texto, uma linha por registro, é o estilo clássico de
Unix: fácil de inspecionar com `echo` e de processar com `awk`, `cut` e
`sort`.

## Destino e trava da base (linhas 111–121)

```bash
if [ -n "$DESTINO" ]; then
  mkdir -p "$DESTINO"
  cd "$DESTINO"
fi

if raiz=$(git rev-parse --show-toplevel 2>/dev/null) && [ -f "$raiz/.agents/skills/desenho/gerar-commits.sh" ]; then
  echo "Esta pasta é a base do projeto (tem a skill em .agents/); os desenhos não vão para ela." >&2
  exit 1
fi
```

Com `--destino`, o script cria a pasta se preciso e passa a trabalhar nela.
Tudo o que vem depois (`git init`, commits, conferência) acontece no destino.

A trava pergunta ao git qual é a raiz do repositório em que está
(`git rev-parse --show-toplevel`) e confere se essa raiz tem o próprio script
em `.agents/skills/desenho/`. Se tiver, é a base, e o script para. Isso cobre
os dois erros mais prováveis: esquecer o `--destino` e passar um destino dentro
da base (como `desenhos-gerados/x`), que o git enxerga como parte do mesmo
repositório.

É uma regra que poderia ficar só na documentação ou na skill, mas no código
ela vale para qualquer pessoa, com ou sem agente.

## Repositório e ano ocupado (linhas 123–133)

```bash
git rev-parse --git-dir >/dev/null 2>&1 || git init -q -b main
```

Se a pasta não for um repositório, cria um na branch `main`.

Depois, se já existe algum commit (`git rev-parse -q --verify HEAD`), conta os
commits do ano com `git log --format=%ad --date=format:%Y | grep -c`. Aqui
aparece o preço do `set -e`: `grep -c` devolve código 1 quando não encontra
nada, o que mataria o script. Daí o `|| true`.

Se o ano já tem commits, o script para. É essa a garantia de "um desenho por
ano" do [capítulo 2](02-grafico-de-contribuicoes.md#por-que-só-um-desenho-por-ano).

## Criação dos commits (linhas 135–150)

```bash
printf '%s\n' "$DIAS" | while read -r data n; do
  for ((i = 1; i <= n; i++)); do
    ts=$(printf '%sT12:%02d:00-03:00' "$data" "$i")
    echo "$data #$i" >> "$LOG"
    git -c core.autocrlf=false add "$LOG"
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" \
      git -c core.autocrlf=false commit -q -m "pixel $data ($i/$n)"
  done
done
```

- **Uma data por commit.** O horário é sempre meio-dia e o minuto é o número
  do commit no dia (12:01, 12:02...). Assim cada commit tem um horário
  diferente e a ordem fica clara no `git log`.
- **As duas datas.** `GIT_AUTHOR_DATE` e `GIT_COMMITTER_DATE` definem as duas
  datas que todo commit tem (veja o [capítulo 5](05-datas-no-git.md)).
- **Por que um arquivo de registro.** Cada commit acrescenta uma linha em
  `desenhos/<nome>.log`, então nenhum commit é vazio e o arquivo serve de
  registro do que foi gerado. `git commit --allow-empty` também funcionaria;
  um arquivo que cresce deixa o histórico mais fácil de inspecionar.
- **`core.autocrlf=false`.** No Windows, o git costuma estar configurado para
  converter fins de linha. Desligar só para esses comandos evita um aviso a
  cada commit e mantém o arquivo igual em qualquer sistema.

Algumas centenas de commits levam alguns minutos, porque cada `git commit` é um
processo novo. Para um projeto desse tamanho, simplicidade vale mais que
velocidade. Com muito mais commits, valeria gerar o histórico de uma vez com
`git fast-import`.

## Conferência (linhas 152–160)

```bash
real=$(git log --format=%ad --date=format:%Y-%m-%d | grep "^$ANO-" | sort | uniq -c | awk '{print $2" "$1}')
[ "$real" = "$DIAS" ]
```

O script lê o que ficou de fato no git, conta os commits por dia e compara com
a lista que saiu da grade. Ele não confia em si mesmo: se algum commit tiver
falhado ou caído no dia errado, a comparação mostra.

`--date=format:` formata a data de autor no fuso gravado no próprio commit
(-03:00), o mesmo usado para criá-los. Como a verificação do ano ocupado
garante que esses são os únicos commits do ano, a comparação é exata.

## Exercícios para quem quer mexer

1. **Limite de horário.** O minuto do commit é o número dele no dia. O que
   acontece com `# niveis: 0 1 3 6 100`? Como mudar o formato do horário para
   aceitar mais de 59 commits por dia?
2. **Simulação.** Acrescente um modo `--simular` que mostre os dias e a
   quantidade de commits sem tocar no git.
3. **Desempenho.** Reescreva o laço de commits usando `git fast-import` e meça
   a diferença.
4. **Prévia no terminal.** Faça o modo `--modelo` aceitar uma grade e imprimi-la
   com `·░▒▓█` no lugar dos níveis.

## Próximo passo

Entenda as datas que o git guarda: [5. Datas no git](05-datas-no-git.md).
