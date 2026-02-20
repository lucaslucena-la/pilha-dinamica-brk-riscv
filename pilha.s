.section .data

# Ponteiro fixo para o início do heap da pilha
base:   .word 0 # .word é usado para reservar 4 bytes

# Ponteiro para o topo atual da pilha
# Também 4 bytes
topo:   .word 0

# Formatos usados no printf
fmt_show:
    .asciz "[%d] "

fmt_endereco:
    .asciz "( %d ) -> Endereço: %p\n"

# Este é o formato para o ÚLTIMO item da lista (a base)
fmt_base_item:
    .asciz "( %d ) -> BASE: %p\n"

fmt_base:
    .asciz "BASE: %p\n"

fmt_topo:
    .asciz "TOPO: %p\n"

fmt_topo_vazio:
    .asciz "(   ) -> TOPO: %p\n"  # Representa o espaço alocado mas vazio

# Formato para mostrar pilha vertical
fmt_vertical:
    .asciz "( %d )\n"

msg_empty_stack:
    .asciz "Pilha vazia!\n"


.section .text

# Funções da pila exportadas para main.s
.globl init_stack
.globl push
.globl pop
.globl show_stack
.globl show_heap_info


# init_stack()
# Inicializa a pilha dinâmica usando brk
# base = topo = endereço atual do heap
init_stack:

    # syscall brk
    li a7, 214
    # retorna break atual, ou seja onde o heap termina atualmente, que é o início da pilha
    li a0, 0
    ecall # a0 agora tem o endereço do início do heap, que será a base da pilha

    # t0 recebe endereço da variável base
    la t0, base

    # salva o endereço do heap em base
    # (início fixo da pilha)
    sw a0, 0(t0) # Armazena o valor retornado pelo SO (em a0) na posição de memória 'base'.

    # t1 recebe endereço da variável topo
    la t1, topo

    # topo começa igual à base (pilha vazia)
    sw a0, 0(t1)# sw: armazena valor de a0 no endereço apontado por t1; topo = base no inicio

    ret
#


# push(x)
# Entrada:
#   a0 = valor a ser inserido
#
# Estratégia:
# 1) topo aponta para o próximo espaço livre
# 2) escrevemos no topo atual
# 3) aumentamos o heap usando brk
# 4) atualizamos topo
push:
    # Reserva espaço na stack (16 bytes)
    addi sp, sp, -16

    # Salva endereço de retorno
    sw ra, 12(sp)

    # Salva valor original
    sw a0, 8(sp) # valor digitado pelo usuário 

    # Carrega topo atual
    la t0, topo     # t0 recebe o endereço da variável topo
    lw t1, 0(t0)      # t1 = endereço do topo atual da pilha, ou seja, o próximo espaço livre onde o valor será inserido

    # Calcula novo topo (4 bytes por inteiro)
    addi t2, t1, 4    # t2 = novo topo

    # ---- Expande o heap ----
    # brk(novo_topo)
    li a7, 214
    mv a0, t2 # a0 recebe o novo topo, que é o endereço para onde queremos expandir o heap
    ecall         # heap cresce até t2

    # Recupera valor salvo
    lw t3, 8(sp)

    # Escreve valor na posição antiga do topo
    sw t3, 0(t1)

    # Atualiza variável topo
    la t4, topo # t4 recebe o endereço da variável topo
    sw t2, 0(t4) # topo = novo topo (t2) 

    # Restaura ra
    lw ra, 12(sp)

    # Libera stack frame
    addi sp, sp, 16
    ret
#


# pop()
# Remove o elemento do topo
#
# Estratégia:
# 1) Se topo == base → pilha vazia
# 2) topo -= 4
# 3) lê valor
# 4) reduz heap com brk
# 5) atualiza topo
# 6) retorna a0 = valor e a1 = status (0 para sucesso, -1 para pilha vazia)
pop:

    addi sp, sp, -16
    sw ra, 12(sp)

    # Carrega base
    la t0, base
    lw t1, 0(t0) # t1 = endereço base

    # Carrega topo
    la t2, topo
    lw t3, 0(t2) # t3 = endereço topo

    # o topo da pilha aponta para o próximo espaço livre, ou seja, o endereço onde o próximo elemento seria inserido. O último elemento da pilha está em t3 - 4, porque cada elemento ocupa 4 bytes (tamanho de um inteiro).

    # Se topo == base → vazia
    beq t1, t3, empty_stack

    # t3 = Novo topo (remove 4 bytes) aponta para o endereço do último elemento
    addi t3, t3, -4

    # Lê valor removido
    lw t5, 0(t3) # t5 = valor do topo da pilha, que é o valor a ser retornado

    # Reduz heap com brk
    li a7, 214
    mv a0, t3
    ecall # heap reduzido para t3, ou seja, topo volta a ser t3 e o valor que estava em t3 é considerado removido da pilha

    # Atualiza topo com valor retornado pelo brk
    la t4, topo
    sw a0, 0(t4)

    # Retorno de Sucesso
    mv a0, t5           # Valor desempilhado vai em a0
    li a1, 0            # Status 0 (Sucesso) vai em a1

    lw ra, 12(sp) # recupero endereço de retorno de pop na main
    addi sp, sp, 16
    ret

    # Tratamento de pilha vazia para pop()
    empty_stack:
        li a1, -1         # Status -1 indica que não há nada para remover
        lw ra, 12(sp)       # Restaura endereço de retorno da função que chamou pop, que é a função main: call pop
        addi sp, sp, 16
        ret # Retorna para a main
    #

#


# show_stack()
# Mostra pilha verticalmente
# Estratégia:
# Percorre do topo - 4 até base, pois topo aponta para o espaço livre após o último elemento
show_stack:

    addi sp, sp, -16
    sw ra, 12(sp) # Salva endereço de retorno
    sw s0, 8(sp)  # Salva s0 (usado para o topo)
    sw s1, 4(sp)  # Salva s1 (usado para a base)

    # s1 = base
    la t0, base
    lw s1, 0(t0) 

    # s0 = topo
    la t1, topo
    lw s0, 0(t1)


    # Se topo == base → vazia
    beq s0, s1, empty_stack_print

    # --- PRINT DO TOPO VAZIO ---
    mv a1, s0 # a1 recebe o endereço do topo para ser mostrado no printf 
    la a0, fmt_topo_vazio # a0 recebe o endereço do formato para imprimir o topo vazio
    call printf # printf( (   ) -> TOPO: %p\n )

    # Começa do último elemento armazenado na pilha
    addi s0, s0, -4 # s0 apontava para o próximo 

    # se entrar aqui é proque há pelo menos um elemento na pilha
    print_loop:

        # Se passou da base → fim
        blt s0, s1, end_show # blt: branch if less than; se s0 < s1, pula para end_show: quer dizer, se topo < base, acabou de imprimir o último elemento

        # Argumentos para o printf:
        # a0 = formato
        # a1 = valor do inteiro (lw 0(s0))
        # a2 = endereço do inteiro (s0)

        # Carrega valor atual que é o valor do topo
        lw a1, 0(s0) # a1 recebe o valor do elemento atual da pilha, topo - 4
        mv a2, s0 # a2 recebe o endereço do elemento atual da pilha, que é o endereço do topo - 4

        # Teste da base
        beq s0, s1, print_base # Se s0 == s1 (endereço atual do elemnto == endereço base)

        la a0, fmt_endereco # a0 recebe o endereço do formato para imprimir verticalmente
        call printf
        j decrementa_ponteiro

    #

    print_base:
        la a0, fmt_base_item # a0 recebe o endereço do formato para imprimir verticalmente
        call printf # printf( ( %d ) -> BASE: %p\n )
        j decrementa_ponteiro 
    #

    decrementa_ponteiro:
        addi s0, s0, -4
        j print_loop
    #

    empty_stack_print:
        la a0, msg_empty_stack
        call printf 
        j end_show
    #

    end_show:
        lw s1, 4(sp)
        lw s0, 8(sp)
        lw ra, 12(sp)
        addi sp, sp, 16
        ret
    #

#


# show_heap_info()
# Mostra endereços base e topo
show_heap_info:
    addi sp, sp, -16
    sw ra, 12(sp)

    # Mostra base
    la t0, base # t0 recebe o endereço da variável base
    lw a1, 0(t0) # a1 recebe o valor armazenado em base, que é o endereço do início do heap (base da pilha)
    la a0, fmt_base 
    call printf

    # Mostra topo
    la t1, topo
    lw a1, 0(t1)
    la a0, fmt_topo
    call printf

    lw ra, 12(sp)
    addi sp, sp, 16
    ret
#



