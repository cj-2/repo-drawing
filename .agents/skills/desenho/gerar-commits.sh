#!/usr/bin/env bash
# Desenha no gráfico de contribuições do GitHub a partir de uma grade de texto,
# criando commits com datas retroativas no repositório git da pasta atual
# (cria um se não existir).
#
# Uso (na pasta do repositório dos desenhos):
#   bash <pasta-da-skill>/gerar-commits.sh --modelo 2021 > barco-2021.txt   # grade vazia
#   bash <pasta-da-skill>/gerar-commits.sh barco-2021.txt                    # cria os commits
#
# Formato da grade:
#   - 7 linhas de células, de Domingo (1ª) a Sábado (7ª); cada caractere é uma
#     coluna (uma semana), como no gráfico do GitHub.
#   - Cada célula é um nível de 0 a 4. Dias fora do ano (início da primeira
#     coluna e fim da última) ficam com ".".
#   - Linhas que começam com "#" são comentários. "# ano: 2021" define o ano
#     (sem ela, o ano vem do nome do arquivo). "# niveis: 0 1 3 6 10" muda a
#     quantidade de commits de cada nível (esse é o padrão).
set -euo pipefail

command -v gawk >/dev/null || { echo "Este script precisa do gawk (vem com o Git Bash)." >&2; exit 1; }

AWK_COMUM='
function inicio(ano) {
  dow0 = strftime("%w", mktime(ano " 1 1 12 0 0")) + 0
  ndias = (ano % 4 == 0 && (ano % 100 != 0 || ano % 400 == 0)) ? 366 : 365
  ncol = int((ndias - 1 + dow0) / 7) + 1
}
# Índice do dia no ano (0 = 1º de janeiro) para a linha r (1-7) e a coluna c.
function indice(r, c) { return (c - 1) * 7 + (r - 1) - dow0 }
'

if [ "${1:-}" = "--modelo" ]; then
  ANO="${2:?Uso: bash gerar-commits.sh --modelo <ano>}"
  gawk -v ano="$ANO" "$AWK_COMUM"'
  BEGIN {
    inicio(ano)
    print "# ano: " ano
    print "# Domingo a Sábado, de cima para baixo. Níveis 0-4; \".\" = dia fora do ano."
    for (r = 1; r <= 7; r++) {
      linha = ""
      for (c = 1; c <= ncol; c++) { i = indice(r, c); linha = linha ((i >= 0 && i < ndias) ? "0" : ".") }
      print linha
    }
  }'
  exit 0
fi

ARG="${1:?Uso: bash gerar-commits.sh <grade.txt>  |  --modelo <ano>}"
[ -f "$ARG" ] || { echo "Grade não encontrada: $ARG" >&2; exit 1; }
GRADE="$ARG"

# Lê e valida a grade. Saída: "ano AAAA" e depois "AAAA-MM-DD N" por dia com commits.
DIAS=$(tr -d '\r' < "$GRADE" | gawk -v arq="$(basename "$GRADE")" "$AWK_COMUM"'
function erro(msg) { print "Erro na grade: " msg > "/dev/stderr"; falhou = 1; exit 1 }
BEGIN {
  split("0 1 3 6 10", N, " ")
  split("Domingo Segunda Terça Quarta Quinta Sexta Sábado", NOME, " ")
}
/^[[:space:]]*#/ {
  if (match($0, /ano:[[:space:]]*([0-9]{4})/, m)) ano = m[1]
  if (match($0, /niveis:[[:space:]]*(.*)$/, m)) {
    if (split(m[1], v, " ") != 5) erro("\"# niveis:\" precisa de 5 números")
    for (i = 1; i <= 5; i++) { if (v[i] !~ /^[0-9]+$/) erro("nível inválido: " v[i]); N[i] = v[i] }
  }
  next
}
/^[[:space:]]*$/ { next }
{ sub(/[[:space:]]+$/, ""); L++; if (L <= 7) linha[L] = $0 }
END {
  if (falhou) exit 1
  if (L != 7) erro("são precisas 7 linhas (Domingo a Sábado), encontrei " L)
  if (!ano) {
    if (match(arq, /(19|20)[0-9][0-9]/, m)) ano = m[0]
    else erro("informe o ano com \"# ano: AAAA\" ou no nome do arquivo")
  }
  inicio(ano)
  for (r = 1; r <= 7; r++) {
    if (length(linha[r]) > ncol) erro(NOME[r] " (linha " r ") tem " length(linha[r]) " colunas; " ano " tem " ncol)
    for (c = 1; c <= ncol; c++) {
      ch = substr(linha[r], c, 1); i = indice(r, c)
      if (i >= 0 && i < ndias) {
        if (ch !~ /^[0-4]$/) erro(NOME[r] ", coluna " c ": esperado nível 0-4, encontrei \"" ch "\"")
      } else if (ch != "" && ch != "." && ch != " ") {
        erro(NOME[r] ", coluna " c ": esse dia não existe em " ano "; use \".\"")
      }
    }
  }
  print "ano " ano
  for (i = 0; i < ndias; i++) {
    c = int((i + dow0) / 7) + 1; r = (i + dow0) % 7 + 1
    n = N[substr(linha[r], c, 1) + 1]
    if (n > 0) print strftime("%Y-%m-%d", mktime(ano " 1 " (i + 1) " 12 0 0")) " " n
  }
}')

ANO=$(printf '%s\n' "$DIAS" | head -1 | cut -d' ' -f2)
DIAS=$(printf '%s\n' "$DIAS" | tail -n +2)
[ -n "$DIAS" ] || { echo "A grade não tem nenhum dia com commits." >&2; exit 1; }

git rev-parse --git-dir >/dev/null 2>&1 || git init -q -b main

# O GitHub soma commits do mesmo dia: só um desenho por ano no repositório.
if git rev-parse -q --verify HEAD >/dev/null; then
  ja=$(git log --format=%ad --date=format:%Y | grep -c "^$ANO$" || true)
  if [ "$ja" -gt 0 ]; then
    echo "Já existem $ja commits em $ANO neste repositório; o desenho ficaria misturado." >&2
    echo "Escolha outro ano ou recrie o repositório (veja o README)." >&2
    exit 1
  fi
fi

total=$(printf '%s\n' "$DIAS" | awk '{s += $2} END {print s}')
echo "$ANO: $total commits em $(printf '%s\n' "$DIAS" | wc -l) dias"

mkdir -p desenhos
LOG="desenhos/$(basename "$GRADE" .txt).log"

printf '%s\n' "$DIAS" | while read -r data n; do
  for ((i = 1; i <= n; i++)); do
    # Meio-dia com fuso fixo evita que o commit "pule" de dia no gráfico do GitHub.
    ts=$(printf '%sT12:%02d:00-03:00' "$data" "$i")
    echo "$data #$i" >> "$LOG"
    git -c core.autocrlf=false add "$LOG"
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" \
      git -c core.autocrlf=false commit -q -m "pixel $data ($i/$n)"
  done
done

# Conferência: commits por dia no git = grade.
real=$(git log --format=%ad --date=format:%Y-%m-%d | grep "^$ANO-" | sort | uniq -c | awk '{print $2" "$1}')
if [ "$real" = "$DIAS" ]; then
  echo "OK: a contagem por dia no git bate com a grade."
else
  echo "ERRO: a contagem por dia no git não bate com a grade." >&2
  exit 1
fi
echo "Registro: $LOG. Para enviar ao GitHub: git push"
