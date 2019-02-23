.globl	_start
.include "macro.s"

STACK_OFFSET = 8
SPACE        = 32

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
    
    call skip_spaces

    cmp $0, %r10
    je ex

    mov %r8, %rsi
    push %r10
    call is_number
    pop %r10
    cmp $0, %rax
    je parse_dec_num

    cmp $1, %rax
    je parse_hex_num

    mov %r8, %rsi
    push %r10
    call is_operator
    pop %r10
    cmp $0, %rax
    jne fail_unsupported_operator

    movb (%r8), %al

    operator_switch
    # jmp lp, if successful

1:
    echo wrong_symbol lwrong_symbol
    jmp fail

parse_dec_num:
    call dec_str_to_num
    jmp save_parsed_num

parse_hex_num:
    add $2, %r8
    sub $2, %r10

    call hex_str_to_num

save_parsed_num:
    push %rax
    mov -8(%rbp), %rax
    inc %rax
    mov %rax, -8(%rbp)
    jmp lp

ex:
    mov -8(%rbp), %rbx
    cmp $1, %rbx # остался 1 элемент в стеке - ответ.
    je  success


fail_stack_not_emty:
    raise_error stack_not_emty, lstack_not_emty
    
fail_div_by_zero:
    raise_error div_by_zero, ldiv_by_zero

fail_too_few_args:
    raise_error too_few_ops, ltoo_few

fail_unsupported_operator:
    raise_error unsupported_operator, lunsupported_operator

fail:
    raise_error unknown_error, lunknown_error

success:
    pop %rax
    call print_num
    exit

.data
    in_buffer: .skip 150
    lin_buffer = . - in_buffer

    newl: .ascii "\n"

    too_few_ops: .ascii "Недостаточно аргументов для оператора\n"
    ltoo_few = . - too_few_ops

    wrong_symbol: .ascii "Неправильный символ во входной строке\n"
    lwrong_symbol = . - wrong_symbol

    unsupported_operator: .ascii "Неподдерживаемый оператор\n"
    lunsupported_operator = . - unsupported_operator

    stack_not_emty: .ascii "В стеке лежит больше одного числа. Добавьте операторов!\n"
    lstack_not_emty = . - stack_not_emty

    div_by_zero: .ascii "Нельзя делить на ноль\n"
    ldiv_by_zero = . - div_by_zero

    unknown_error: .ascii "Что-то пошло не так :(\n"
    lunknown_error = . - unknown_error

    overflow_warning: .ascii "Множители получились слишком большие. Часть результата потерялась :(\n\n"
    loverflow_warning = . - overflow_warning


.text
# # #
# Функции малютки
# # #

plus_op:
    add %rbx, %rax
    ret

minus_op:
    sub %rax, %rbx
    xchg %rax, %rbx
    ret

mult_op:
    imul %rbx, %rax     # по документации: если результат > 64 бит, выставятся CF и OF
    call check_mult_overflow   
    ret

div_op:
    xchg %rax, %rbx
    xor   %rdx, %rdx
	cqo
    cmp $0, %rbx
    je  fail_div_by_zero
	idiv	%rbx
    ret

remainder_op:
    call div_op
    mov  %rdx, %rax
    ret

and_op:
    and %rbx, %rax
    ret

or_op:
    or %rbx, %rax
    ret

xor_op:
    xor %rbx, %rax
    ret

unar_min_op:
    mov $0,  %rbx
    sub %rax, %rbx
    mov %rbx, %rax
    ret

modulo_op:
    cmp $0, %rax
	jl mod_negative
    ret

    mod_negative:
        call unar_min_op
        ret

sgn_op:
    cmp $0, %rax
	jl sgn_negative
    cmp $0, %rax
	jg sgn_positive
    ret

    sgn_negative:
        mov $-1, %rax
        ret

    sgn_positive:
        mov $1, %rax
        ret

power_op:
    xchg %rbx, %rax
    dec %rbx
    mov %rax, %rcx
    power_lp:
        cmp $0, %rbx
        je power_ex
        imul %rcx, %rax
        call check_mult_overflow
        cmp $0, %rdx
        jne power_ex
        dec %rbx
        jmp power_lp

    power_ex:
        ret

check_mult_overflow:
    jnc ok

    pushf
    pop %rdx
    shr  $1, %rdx
    jnc  ok

    echo overflow_warning, loverflow_warning
    mov $1, %rdx
    ret

    ok:
        xor %rdx, %rdx
        ret

skip_spaces:
    movb (%r8), %al    # letter
    mov $SPACE, %bl
    cmp %al, %bl
    je skip_char
    ret

    skip_char:
        inc %r8
        dec %r10
        jmp skip_spaces
