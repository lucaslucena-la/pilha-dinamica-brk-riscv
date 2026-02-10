# Pilha Dinâmica no Heap usando brk (RISC-V)

## 📌 Descrição Geral

Este projeto implementa uma **pilha de inteiros (32 bits)** alocada dinamicamente no **heap**, utilizando **exclusivamente a syscall `brk`**, conforme solicitado no enunciado da Parte 1 do trabalho de Organização de Computadores.

A pilha **não utiliza a stack da CPU** para armazenamento dos dados, apenas para chamadas de função.  
A política adotada é **LIFO (Last In, First Out)**, garantindo que a liberação de memória seja correta ao reduzir o program break.

## 🎯 Objetivos do Trabalho

- Implementar uma pilha dinâmica no heap
- Utilizar apenas a syscall `brk` para:
  - Alocar memória
  - Liberar memória
- Demonstrar:
  - Crescimento do heap no `push`
  - Redução do heap no `pop`
  - Comportamento LIFO da pilha
- Validar o funcionamento por meio de **depuração com GDB**

## 🧠 Conceito de Funcionamento

- O **heap cresce para endereços maiores**
- O **program break** aponta para o topo do heap
- O registrador `s1` é utilizado como:
  - **Topo da pilha**
- Cada elemento da pilha ocupa **4 bytes (1 inteiro)**

### Operações

#### `push(x)`

1. Calcula novo break: `s1 + 4`
2. Chama `brk(s1 + 4)`
3. Armazena `x` em `0(s1)`
4. Atualiza `s1 = s1 + 4`

#### `pop()`

1. Atualiza `s1 = s1 - 4`
2. Recupera o valor armazenado em `0(s1)`
3. Reduz o program break com `brk(s1)`

## 🛠️ Compilação e Execução

### Compilação

```bash
riscv64-linux-gnu-as -g -march=rv32im -mabi=ilp32 pilha.s -o pilha.o
riscv64-linux-gnu-ld -m elf32lriscv pilha.o -o pilha.exe
```

### Execução normal

```bash
qemu-riscv32 pilha.exe
```

## 🐞 Depuração com GDB (Passo a Passo Completo)

1. **Iniciar o QEMU em modo debug (Terminal 1)**

   ```bash
   qemu-riscv32 -g 1234 pilha.exe
   ```

2. **Iniciar e Conectar o GDB (Terminal 2)**

   ```bash
   gdb-multiarch pilha.exe
   (gdb) target remote :1234
   ```

3. **Ver Instruções do programa**

   ```bash
   (gdb) x/6i $pc
   ```

   **Exemplo:**

   ```
   =>  li a7,214
       li a0,0
       ecall
       mv s1,a0
       li t0,5
       jal push
   ```

4. **Executar inicialização passo a passo**

   ```bash
   (gdb) stepi
   (gdb) stepi
   (gdb) stepi
   (gdb) stepi
   ```

   **Verificar Topo da pilha**

   ```bash
   (gdb) info registers s1
   ```

5. **Entrar na função `push`**

   ```bash
   (gdb) stepi

   (gdb) x/6i $pc
   ```

   **Exemplo Real:**

   ```
   li a7,214
   addi a0,s1,4
   ecall
   sw t0,0(s1)
   addi s1,s1,4
   ret
   ```

6. **Debug do Push**

   **Verificar o novo topo da pilha após o push**

   ```bash
   (gdb) info registers s1
   ```

   **Executar Instruções:**

   ```bash
   (gdb) stepi   # li a7,214
   (gdb) stepi   # addi a0,s1,4
   (gdb) stepi   # ecall
   (gdb) stepi   # sw t0,0(s1)
   (gdb) stepi   # addi s1,s1,4
   ```

   **Ver topo da pilha após o push:**

   ```bash
   (gdb) info registers s1
   ```

   **Ver Valor no heap:**

   ```bash
   (gdb) x/1w $s1-4
   ```

7. **Voltar ao Programa prncipal**

   ```bash
   (gdb) stepi   # ret
   ```

8. **Colocar breakpoint no início real do `pop`**

   ```bash
   (gdb) break *pop
   (gdb) continue
   ```

   O uso de `break *pop` garante que o breakpoint seja colocado no início real da função, antes das instruções de desempilhamento.

9. **Ver conteúdo do `pop`**

   ```bash
   (gdb) x/6i $pc
   ```

   **Exemplo Real:**

   ```
   addi sp,sp,-16
   sw ra,0(sp)
   addi s1,s1,-4
   lw t0,0(s1)
   ```

10. **Debug do Pop**
    **Executar Instruções até o desempilhamento :**

    ```bash
    (gdb) stepi   # addi sp,sp,-16
    (gdb) stepi   # sw ra,0(sp)
    (gdb) stepi   # addi s1,s1,-4
    ```

    **Ver topo após redução:**

    ```bash
    (gdb) info registers s1
    ```

    **Ver valor desempilhado:**

    ```bash
    (gdb) info registers t0
    ```
