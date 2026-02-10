.section .data 
msg_pop: .asciz "Pop: "

.section .text
.globl _start

_start:

li a7, 214  # carrega em a7o número da syscall brk
li a0, 0    # argumento 0: solicitar o break atual
ecall

mv s1, a0   # inicializa o topo da pilha (s1 = break atual)

li t0, 5   # carrega o valor 5 para empilhar

jal ra, push    # chama função push(10)

li t0, 6   # carrega o valor 6 para empilhar
jal ra, push    # chama a função push (20)

li t0, 8   # carrega o valor 8 para empilhar
jal ra, push    # chama a função push (30)

jal ra, pop     
jal ra, pop 
jal ra, pop


li a7, 10   # syscall exit
li a0, 0    # código de saída
ecall



# Função Push
# Entrada: t0 -> inteiro a ser empilhado
# s1 -> topo da pilha (program break)


push:

    li a7, 214
    addi a0, s1, 4    # novo break = topo + 4
    ecall           # aloca esapço no heap

    # Armazena o valor no topo atual
    sw t0, 0(s1)

    # Atualiza o topo da pilha
    addi s1, s1, 4

    ret


# Função Pop
# Remove o topo da pilha e imprime o valor desempilhado

pop:

    # salvando ra, pois faremos ecalls dentro da função
    addi sp, sp, -16
    sw ra, 0(sp)

    # Atualiza o topo da pilha
    addi s1, s1, -4

    # Lê o valor do topo
    lw t0, 0(s1)

    li a7, 64       # syscall write
    li a0, 1        # file descriptor 1 (stdout)
    la a1, msg_pop  # endereço da mensagem "Pop: "
    li a2, 5        # tamanho da mensagem
    ecall

    addi t0, t0, 48 # Converte inteiro (0–9) para ASCII
    sb t0, 8(sp)   # Armazena caractere na stack da CPU

    li a7, 64       # syscall write
    li a0, 1        # file descriptor 1 (stdout)
    addi a1, sp, 8 # endereço do caractere a ser impresso
    li a2, 1        # tamanho do caractere
    ecall

    li t1, 10       # código ASCII para '\n'
    sb t1, 9(sp)   # armazena '\n'
    li a7, 64       
    li a0, 1
    addi a1, sp, 9
    li a2, 1
    ecall
    
    li a7, 214      # syscall brk
    mv a0, s1       # Novo program break (liberação)
    ecall           # Libera memória do heap

    lw ra, 0(sp)
    addi sp, sp, 16

    ret
