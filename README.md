# Pilha Dinâmica no Heap com Syscall BRK (RISC-V)

Este projeto implementa uma **Pilha de Inteiros** alocada dinamicamente no **Heap** utilizando exclusivamente a chamada de sistema `brk` (syscall 214) da arquitetura RISC-V. Diferente de uma pilha convencional que utiliza o registrador `sp` (Stack Pointer), esta implementação gerencia manualmente o *Program Break* do processo para alocar e liberar memória.

## 📋 Especificações Técnicas

* **Arquitetura:** RISC-V (RV64).
* **Linguagem:** Assembly.
* **Gerenciamento de Memória:** Direto via Syscall `brk` (214).
* **Política de Dados:** LIFO (*Last In, First Out*).
* **Tamanho do Elemento:** 4 bytes (Inteiro de 32 bits).

## 🛠️ Estrutura do Projeto

O projeto é dividido em dois módulos principais:

1.  **`pilha.s`**: Contém a lógica de baixo nível para manipulação do Heap.
    * `init_stack`: Captura o endereço inicial do heap.
    * `push`: Expande o heap e insere um valor.
    * `pop`: Recupera o valor e reduz o heap (liberação real de memória).
    * `show_stack`: Percorre a memória do heap para exibir os elementos.
    * `show_heap_info`: Exibe os endereços hexadecimais da base e do topo.

2.  **`main.s`**: Interface de usuário via terminal (Menu interativo) que utiliza as funções da biblioteca `pilha.s`.

## 🚀 Como Executar

O projeto utiliza um `Makefile` para facilitar a compilação cruzada e execução via emulador QEMU.

### Pré-requisitos
* GCC para RISC-V (`riscv64-linux-gnu-gcc`)
* QEMU para RISC-V (`qemu-riscv64`)

### Comandos
Para compilar o projeto:
```bash
make
```
Para executar o projeto:
```bash
make run
```
Para limpar os arquivos gerados:
```bash
make clean
```