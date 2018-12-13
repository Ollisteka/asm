.globl	_start
.include "macro.s"

STACK_OFFSET = 64
DEC_BASE = 10
SPACE = 32
NEWL = 0xa
MULT 	 = 42
PLUS     = 43
MINUS 	 = 45
DIVIDE 	 = 47
UNAR_MINUS = 126
RADIX    = 10

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
    mov -8(%rbp), %r10    # length

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

    movb (%r8), %al
    cmp $PLUS, %al
    jne 1f
    exec_bin_operation plus_op

1:
    cmp $MINUS, %al
    jne 1f
    exec_bin_operation minus_op

1:
    cmp $UNAR_MINUS, %al
    je unar_min_op

    echo wrong_symbol lwrong_symbol
    jmp fail

parse_dec_num:
    xor %rax, %rax
    xor %rbx, %rbx
    xor %rcx, %rcx
    mov $RADIX, %bx

p_start_lp:
    cmp  $0, %r10
    je p_end_lp

    movb (%r8), %cl
    cmp  $SPACE, %cl
    je p_end_lp
    
    sub     $0x30,  %cl
    mul     %rbx  # ax = ax*cx 

    add     %rcx,    %rax  # rax = rax*10 + cx 

    inc     %r8
    dec     %r10
    jmp     p_start_lp

p_end_lp:
    push %rax
    mov -24(%rbp), %rax
    inc %rax
    mov %rax, -24(%rbp)
    jmp lp

plus_op:
    add %rbx, %rax
    ret

minus_op:
    sub %rax, %rbx
    xchg %rax, %rbx
    ret

unar_min_op:
    dec %r10
    inc  %r8
    mov -24(%rbp), %rax
    cmp $0, %rax
    je  fail_too_few_args
    pop %rax
    mov $0,  %rbx
    sub %rax, %rbx
    push %rbx
    jmp lp


ex:
    mov -24(%rbp), %rbx
    cmp $1, %rbx # остался 1 элемент в стеке - ответ.
    je  success

fail_too_few_args:
    echo too_few_ops, ltoo_few

fail:
    exit

success:
    pop %rax
    call print_num
    exit

.data
    example: .ascii "1"
    lexample = . - example

    result: .ascii "Fail\n"

    in_buffer: .skip 50
    lin_buffer = . - in_buffer

    newl: .ascii "\n"

    too_few_ops: .ascii "Недостаточно аргументов для оператора\n"
    ltoo_few = . - too_few_ops

    wrong_symbol: .ascii "Неправильный символ во входной строке\n"
    lwrong_symbol = . - wrong_symbol

