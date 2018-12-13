.globl	is_dec_number
.include "macro.s"

# args:
# %rsi - указатель на строку
# %r10 - длина строки

# returns:
# rax: 0 - десятичное число, 1 - hex (not implemented), 2 - не число
.text
is_dec_number:
   run_fsm ss, ls

fail:
    mov $2, %rax
    ret

success:
    mov $0, %rax
    ret

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cycle_numbers 0, 1
        cell 0, 0, 3
    s1: cell 1, 0, 1
        cycle_numbers 1, 1
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
