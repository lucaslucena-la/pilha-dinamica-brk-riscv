.section .data
menu:
    .asciz "\n1- Push\n2- Pop\n3- Mostrar pilha\n4- Mostrar base/topo\n5- Sair\nOpcao: "

fmt_int:
    .asciz "%d"

msg_push:
    .asciz "Digite valor: "

msg_pop:
    .asciz "Removido: %d\n"

msg_empty:
    .asciz "Pilha vazia!\n"

.section .bss
opcao: .space 4 # Variável para armazenar a opção do menu (4 bytes para um inteiro) 
valor: .space 4 # Variável para armazenar o valor a ser empilhado (4 bytes para um inteiro)

.section .text
.globl main

main:
    addi sp, sp, -16
    sw ra, 12(sp)

    call init_stack # inicializa a base e o topo da pilha 

menu_loop:

    la a0, menu # a0 recebe o endereço do menu para imprimir
    call printf # Exibe o menu na tela printf(menu)

    la a0, fmt_int # a0 recebe o endereço do formato para ler um inteiro
    la a1, opcao # a1 recebe o endereço da variável opcao para armazenar a escolha do usuário
    call scanf # scanf(fmt_int, &opcao) lê a opção digitada pelo usuário e armazena em opcao

    lw t0, opcao # t0 recebe o valor da escolha do usuário digitada no teclado

    li t1, 1
    beq t0, t1, op_push

    li t1, 2
    beq t0, t1, op_pop

    li t1, 3
    beq t0, t1, op_show

    li t1, 4
    beq t0, t1, op_info

    li t1, 5
    beq t0, t1, op_exit

    j menu_loop


op_push:

    la a0, msg_push # "Digite valor: "
    call printf # printf(msg_push) exibe a mensagem para o usuário digitar um valor

    # ler o valor do teclado
    la a0, fmt_int     # Formato "%d"
    la a1, valor       # Endereço da variável 'valor' no .bss
    call scanf         # O scanf pega o que foi digitado e guarda em 'valor'

    lw a0, valor # a0 recebe o valor digitado pelo usuário para ser empilhado
    call push # chama a função push para empilhar o valor

    j menu_loop


op_pop:

    call pop # a0 = valor do elemento que foi removido, a1 = status da operação (0 para sucesso, -1 para pilha vazia)
    li t0, -1 
    beq a1, t0, empty_msg # se pop retornar -1, significa que a pilha estava vazia

    mv a1, a0 # a1 recebe o valor removido da pilha para ser impresso
    la a0, msg_pop # a0 recebe o endereço da mensagem para imprimir o valor removido
    call printf # Exibe o valor na tela
    j menu_loop

empty_msg:

    la a0, msg_empty
    call printf
    j menu_loop


op_show:
    call show_stack
    j menu_loop

op_info:
    call show_heap_info
    j menu_loop


op_exit:
    lw ra, 12(sp)
    addi sp, sp, 16

    li a0, 0
    li a7, 93
    ecall
