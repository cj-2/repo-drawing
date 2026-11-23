# 3. A grade de texto

Cada desenho é um arquivo `<nome>-<ano>.txt`. É o formato mais simples que
ainda dá para editar à mão, ler num diff e um agente gerar sem erro.

## Exemplo: `jardim-2019.txt`

```
# ano: 2019
# jardim — Domingo a Sábado, de cima para baixo. Níveis 0-4; "." = dia fora do ano.
.0020200000004000000000303000000002000002220000000000
.0224220000444440000022303220000024200024442000000000
00022200444444444440220333022000002000002220000000000
0000300001141114110000003000000010300000030000020020.
0011300001111311110000444440000001301000031100223322.
0000311030222222203000044400000000310001130000003300.
1111311133122222133111144411111111311111131111113311.
```

## As regras

- **7 linhas de células**, de domingo (1ª) a sábado (7ª), como no gráfico.
- **Cada caractere é uma coluna**, ou seja, uma semana.
- **Cada célula é um nível de 0 a 4**, que vira 0, 1, 3, 6 ou 10 commits.
- **`.` marca um dia que não existe no ano**: o começo da primeira coluna e o
  fim da última.
- **Linhas com `#` são comentários.** Duas têm significado:
  - `# ano: 2019` define o ano. Sem ela, o script procura o ano no nome do
    arquivo;
  - `# niveis: 0 1 3 6 10` muda quantos commits cada nível vale (o padrão é
    esse).
- Linhas em branco são ignoradas, e o `\r` do fim de linha do Windows também.

Não é preciso calcular onde ficam os `.`: `gerar-commits.sh --modelo 2019`
imprime a grade vazia já certa, e o desenho começa a partir dela.

## A conta que liga a grade às datas

Essa é a parte que vale entender. Tudo sai de um número: **o dia da semana de
1º de janeiro**, chamado no script de `dow0` (0 = domingo … 6 = sábado). Em
2019, 1º de janeiro foi uma terça, então `dow0 = 2`.

Pense na grade como uma fila de 7 em 7 dias que começa num domingo. Se
numerarmos os dias do ano a partir de 0 (`i = 0` é 1º de janeiro), o dia `i`
ocupa a posição `i + dow0` dessa fila. Os `dow0` primeiros lugares ficam vazios.

**Da data para a célula:**

```
coluna = (i + dow0) / 7 + 1     (divisão inteira)
linha  = (i + dow0) % 7 + 1
```

**Da célula para a data** (é a função `indice` do script):

```
i = (coluna - 1) * 7 + (linha - 1) - dow0
```

Se `i` der negativo ou passar do último dia do ano, a célula é um `.`.

**Quantas colunas tem o ano:**

```
ncol = (ndias - 1 + dow0) / 7 + 1     (ndias = 365 ou 366)
```

### Exemplo resolvido: 4 de julho de 2019

1. 4 de julho é o dia `i = 184` do ano (31 + 28 + 31 + 30 + 31 + 30 + 3).
2. `i + dow0 = 186`.
3. Coluna: `186 / 7 = 26`, mais 1 → **coluna 27**.
4. Linha: `186 % 7 = 4`, mais 1 → **linha 5, quinta-feira**. E 4/7/2019 foi
   mesmo uma quinta.
5. Na grade do jardim, a linha 5 coluna 27 tem `4`, então esse dia recebe
   **10 commits**.

Confira as bordas: na linha 1 (domingo), coluna 1, `i = 0 + 0 - 2 = -2`, que
não existe, então é `.`. Na linha 3 (terça), coluna 1, `i = 0`: 1º de janeiro.

## Por que bissexto e dia da semana mudam a grade

Um mesmo desenho não serve em qualquer ano sem conferência: o `dow0` muda os
`.` da primeira e da última coluna, e um ano pode ter 53 ou 54 colunas. Ao
adaptar uma grade de um ano para outro, mantenha as colunas e confira as
bordas. Foi o que aconteceu com a baleia, desenhada para 2020 e adaptada para
2018: ela fica longe das bordas, então coube nas mesmas colunas. Só as células
das bordas mudaram, para acompanhar os `.` de 2018.

## Limites do desenho

São 7 pixels de altura e cerca de 53 de largura, com 5 tons. Algumas regras
práticas que a skill segue:

- formas simples e blocos de uma cor só;
- separar partes por contraste (claro ao lado de escuro), não por pixels
  soltos;
- cada mês tem 4 ou 5 colunas, o que ajuda a posicionar o desenho ("em
  março", "no fim do ano").

## Próximo passo

Veja como o script lê esse arquivo: [4. O script `gerar-commits.sh`](04-script-gerar-commits.md).
