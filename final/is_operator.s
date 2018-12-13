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
    and:  cell 0, "a", 7
          cell 7, "n", 8
          cell 8, "d", 9
    or: cell 0, "o", 10
        cell 10, "r", 11
    xor:  cell 0, "x", 12
          cell 12, "o", 13
          cell 13, "r", 14
    modulo:  cell 0, "|", 15
             cell 15, "|", 16
    sign:  cell 0, "<", 15
           cell 15, ">", 16

    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
