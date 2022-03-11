# RISC-V Multiciclo

Artefatos codificados por Luiz Carlos Schonarth Junior, matrícula 19/0055171, UnB - Universidade de Brasília

## Montando e executando código no terminal

### Pré-requisitos para executar no terminal
- Sistema operacional Unix.
- Pacote `ghdl` para análise, elaboração e execução do código.
- Pacote `gtkwave` para visualização da forma de onda dos sinais do código.

Em um terminal, mude para o diretório de trabalho, onde se econtram as pastas `packages`, `src` e `test`, e execute:

```
$ ghdl -a --workdir=./build -fsynopsys packages/* src/* test/RiscV_tb.vhd
$ ghdl elab-run --workdir=./build -fsynopsys RiscV_tb
```

Para analisar a forma de onda da testbench usando o `gtkwave`, 
execute os comandos acima e execute também:

```
$ ghdl elab-run --workdir=./build -fsynopsys RiscV_tb --vcd=RiscV.vcd
$ gtkwave RiscV.vcd

```

## Montando e executando código no Modelsim

Mude o diretório de trabalho no Modelsim para o diretório raiz do projeto.

No menu no topo da janela, selecione a opção `Compile` e compile todos os arquivos da pasta `packages`, `src` e o arquivo `RiscV_tb` da pasta `test`.

Após a compilação, selecione a opção `Start simulation` no menu do topo da janela e digite `RiscV_tb` no input para "Design Unit(s)".

Use os ícones do menu de ferramentas na janela para executar o programa ou, opcionalmente, na tela do console do Modelsim, digite `run -all` para executar o testbench por completo ou digite `run 1ns` para simular a testbench iterativamente.

Para visualizar a forma de onda, assegure-se que a opção `View->Locals` e `View->Wave` estão habilitadas.

