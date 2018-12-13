.globl	is_operator
.include "macro.s"

# args:
# %rsi - указатель на строку
# %r10 - длина строки

# returns:
# rax: 0 - оператор, 1 - не оператор
.text
is_operator:
    run_fsm ss, ls

fail:
    mov $1, %rax
    ret

success:
    mov $0, %rax
    ret

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cell 0, "+", 1
        cell 0, "*", 2
        cell 0, "-", 3
        cell 0, "/", 4
        cell 0, "~", 5
        cell 0, "%", 6
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
