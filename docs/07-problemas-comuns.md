# 7. Problemas comuns

## O desenho não aparece no perfil

Confira nesta ordem:

1. **O e-mail.** Os commits usam o `user.email` do git. Ele precisa estar
   cadastrado e verificado em Settings → Emails. Para ver o e-mail de um commit
   no GitHub, acrescente `.patch` ao fim da URL do commit.
2. **A branch.** Só a branch padrão conta. Confira com
   `git branch --show-current` e nas configurações do repositório no GitHub.
3. **Repositório privado.** Ative "Private contributions" no perfil.
4. **Fork.** Commits num fork normalmente não contam. Use um repositório
   próprio.
5. **Tempo.** Espere alguns minutos depois do `git push`, às vezes mais.

## Os tons ficaram parecidos

O GitHub calcula as cores em relação aos seus próprios dias (veja o
[capítulo 2](02-grafico-de-contribuicoes.md#as-cores-são-relativas)). Afaste os
valores com uma linha na grade:

```
# niveis: 0 1 5 10 20
```

Os commits já criados não mudam, então é preciso gerar o desenho de novo num
repositório recriado.

## "Já existem N commits em AAAA neste repositório"

O script recusa um ano que já tem commits para não misturar dois desenhos.
Saídas:

- escolher outro ano;
- recriar o repositório dos desenhos: apagar o repositório no GitHub e, na
  pasta, só `.git` e `desenhos/`, e gerar de novo a partir das grades.

## "Erro na grade: ..."

A mensagem diz o dia da semana (linha) e a coluna:

| Mensagem | Causa provável |
|---|---|
| são precisas 7 linhas | Uma linha a mais ou a menos, ou uma linha de célula começando com `#` |
| tem N colunas; AAAA tem M | Grade de outro ano ou caracteres a mais no fim |
| esperado nível 0-4 | Letra, espaço ou outro número no meio da linha |
| esse dia não existe em AAAA; use "." | Nível na borda, onde o ano ainda não começou ou já acabou |
| informe o ano | Sem `# ano:` e sem ano no nome do arquivo |

A forma mais segura de corrigir é gerar a grade vazia do ano certo com
`--modelo` e copiar o desenho para ela, coluna por coluna.

## "Este script precisa do gawk"

No Windows, rode pelo Git Bash, que já traz o `gawk`. No macOS, instale com
`brew install gawk`. No Linux, pelo gerenciador de pacotes (`apt install gawk`).

## Avisos "LF will be replaced by CRLF"

São avisos do git no Windows, quando `core.autocrlf` está ligado. Não afetam
os desenhos: o script desliga a conversão nos próprios commits, e a leitura da
grade remove o `\r`. Nos commits normais deste repositório, os avisos podem
aparecer ao adicionar as grades; são inofensivos.

## Gerei os commits no repositório errado

O script trabalha no repositório git da pasta atual. Se rodou numa pasta que
tinha outro histórico (por exemplo, este repositório de documentação), os
commits retroativos se misturaram com os do projeto.

Se ainda não fez `git push`, volte ao último commit antes deles. Ache o hash
com `git log --oneline` (os gerados têm a mensagem `pixel AAAA-MM-DD (i/n)`) e
rode:

```bash
git reset --hard <hash-do-último-commit-bom>
```

Isso apaga os commits gerados e qualquer mudança não salva na pasta, então
confira o hash antes. Se já enviou, o histórico remoto também precisa ser
corrigido, o que exige `git push --force` e cuidado redobrado.

Para evitar o problema, gere os desenhos sempre numa pasta própria:

```bash
git clone https://github.com/<seu-usuario>/repo-draw.git ../repo-draw-desenhos
cp baleia-2018.txt ../repo-draw-desenhos/
cd ../repo-draw-desenhos
bash ../repo-draw/.agents/skills/desenho/gerar-commits.sh baleia-2018.txt
```

## O agente parou no passo 1 mesmo com a grade pronta

Versões antigas da skill paravam ao achar uma grade do ano. A versão atual
trata uma grade sem commits como "desenho ainda não gerado" e tem a seção
"Recriar a partir de grades existentes". Se o seu agente usa uma cópia
instalada globalmente, atualize-a com `npx skills add cj-2/repo-draw -g`.
