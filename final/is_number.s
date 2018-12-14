.globl	is_number
.include "macro.s"

# args:
# %rsi - указатель на строку
# %r10 - длина строки

# returns:
# rax: 0 - десятичное число, 1 - hex, 2 - не число
.text
is_number:
   run_fsm ss, ls

fail:
    mov $2, %rax
    ret

success:
    cmp $5, %dl
    je ret_hex

    ret_dec:
        mov $0, %rax    
        ret

    ret_hex:
        mov $1, %rax    
        ret

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cycle_numbers 0, 1
        cell 0, 0, 3
    dec: cell 1, 0, 1
        cycle_numbers 1, 1
    hex: cell 3, "x", 4
         cycle_hex_symbols 4, 5 # 0x - невалидно
         cycle_hex_symbols 5, 5
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
