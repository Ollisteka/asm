.globl	_start
.include "macro.s"

STACK_OFFSET = 64
DEC_BASE = 10
SPACE = 32

.text
_start:
    read $in_buffer, $lin_buffer # в rax - количество прочитанных символов, включая \n  
    dec  %rax

    mov %rsp, %rbp
    sub $STACK_OFFSET, %rsp
    mov %rax, -8(%rbp)   # длина прочитанного выражения
    movq $0, -16(%rbp)  # что считали: 0 - оператор, 1 - десятичное число, 2 - hex
    movq $0, -24(%rbp)  # текущий размер стека
    movq $0, -32(%rbp)  # сюда буду ложить распарсенную циферку
    movq $0, -40(%rbp)  # здесь сохраню число-переход

    echo newl


    mov $in_buffer, %r8   # str
    mov -8(%rbp), %r10  # length

lp:
    cmp $0, %r10
    je ex
    
skip_space:
    movb (%r8), %al    # letter
    mov $SPACE, %bl
    cmp %al, %bl
    je 1f
    jmp cont

1:
    inc %r8
    dec %r10
    jmp skip_space
    

cont:
    mov %r8, %rsi
    push %r10
    call is_dec_number
    pop %r10
    cmp $0, %rax
    je parse_dec_num
    jmp lp

parse_dec_num:
    jmp lp

ex:
    add $48, %dl
    movb %dl, result
    jmp print

fail:
    jmp print

print:
    echo result, 2
    exit

.data
    example: .ascii "1"
    lexample = . - example

    result: .ascii "F\n"

    in_buffer: .skip 50
    lin_buffer = . - in_buffer

    newl: .ascii "\n"

