.globl	_start
.include "macro.s"

STACK_OFFSET = 16
DEC_BASE = 10
SPACE    = 32
NEWL     = 10
MULT 	 = 42
PLUS     = 43
MINUS 	 = 45
DIVIDE 	 = 47
UNAR_MINUS = 126
RADIX    = 10

.text
_start:
    read $in_buffer, $lin_buffer # в rax - количество прочитанных символов, включая \n  
    dec %rax
    mov %rax, %r10    # длина входной строки (без перевода строки)

    mov %rsp, %rbp
    sub $STACK_OFFSET, %rsp
    movq $0, -8(%rbp)  # текущий размер стека

    echo newl

    mov $in_buffer, %r8   # str
    

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
    cmp $0, %r10
    je ex

    mov %r8, %rsi
    push %r10
    call is_dec_number
    pop %r10
    cmp $0, %rax
    je parse_dec_num

    push %r10
    call is_operator
    pop %r10
    cmp $0, %rax
    jne fail_unsupported_operator

    movb (%r8), %al
    cmp $PLUS, %al
    jne 1f
    exec_bin_operation plus_op

1:
    cmp $MINUS, %al
    jne 1f
    exec_bin_operation minus_op

1:
    cmp $MULT, %al
    jne 1f
    exec_bin_operation mult_op

1:
    cmp $DIVIDE, %al
    jne 1f
    exec_bin_operation div_op

1:
    cmp $UNAR_MINUS, %al
    je unar_min_op

    echo wrong_symbol lwrong_symbol
    jmp fail

parse_dec_num:
    call dec_str_to_num

    push %rax
    mov -8(%rbp), %rax
    inc %rax
    mov %rax, -8(%rbp)
    jmp lp

plus_op:
    add %rbx, %rax
    ret

minus_op:
    sub %rax, %rbx
    xchg %rax, %rbx
    ret

mult_op:
    imul %rbx, %rax
    ret

div_op:
    xchg %rax, %rbx
    xor   %rdx, %rdx
	cqo
    cmp $0, %rbx
    je  fail_div_by_zero
	idiv	%rbx
    ret

unar_min_op:
    dec %r10
    inc  %r8
    mov -8(%rbp), %rax
    cmp $0, %rax
    je  fail_too_few_args
    pop %rax
    mov $0,  %rbx
    sub %rax, %rbx
    push %rbx
    jmp lp


ex:
    mov -8(%rbp), %rbx
    cmp $1, %rbx # остался 1 элемент в стеке - ответ.
    je  success

fail_stack_not_emty:
    echo stack_not_emty lstack_not_emty
    exit
    
fail_div_by_zero:
    echo div_by_zero ldiv_by_zero
    exit

fail_too_few_args:
    echo too_few_ops, ltoo_few
    exit

fail_unsupported_operator:
    echo unsupported_operand, lunsupported_operand
    exit

fail:
    echo unknown_error lunknown_error
    exit

success:
    pop %rax
    call print_num
    exit

.data
    in_buffer: .skip 50
    lin_buffer = . - in_buffer

    newl: .ascii "\n"

    too_few_ops: .ascii "Недостаточно аргументов для оператора\n"
    ltoo_few = . - too_few_ops

    wrong_symbol: .ascii "Неправильный символ во входной строке\n"
    lwrong_symbol = . - wrong_symbol

    unsupported_operand: .ascii "Непооддерживаемый оператор\n"
    lunsupported_operand = . - unsupported_operand

    stack_not_emty: .ascii "В стеке лежит больше одного числа. Добавьте операторов!\n"
    lstack_not_emty = . - stack_not_emty

    div_by_zero: .ascii "Нельзя делить на ноль\n"
    ldiv_by_zero = . - div_by_zero

    unknown_error: .ascii "Что-то пошло не так :(\n"
    lunknown_error = . - unknown_error
