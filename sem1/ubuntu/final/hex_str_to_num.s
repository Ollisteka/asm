
.globl	hex_str_to_num
.include "macro.s"

RADIX = 16
SPACE = 32
ZERO  = 48
NINE  = 57
A_LIT = 65
B_LIT = 66
C_LIT = 67
D_LIT = 68
E_LIT = 69
F_LIT = 70
A_BIG = 97
B_BIG = 98
C_BIG = 99
D_BIG = 100
E_BIG = 101
F_BIG = 102

# args:
# %r8 - указатель на строку
# %r10 - длина строки

# returns:
# rax: десятичное число

hex_str_to_num:
    xor %rax, %rax
    xor %rbx, %rbx
    xor %rcx, %rcx
    mov $RADIX, %bx

lp:
    cmp  $0, %r10
    je ex

    movb (%r8), %cl

    cmp  $SPACE, %cl
    je   ex

    cmp  $NINE, %cl
    ja   check_hex

    # cmp  $ZERO, %cl
    # jb   ex
    # ошибка, но эта функция всегда вызывается после регвыра. Т.е. я уверена, что это валидный хекс, и такой ситуации не будет

    sub     $0x30,  %cl

    mult:
        mul     %rbx  # ax = ax*cx 

        add     %rcx,    %rax  # rax = rax*16 + cx 

        inc     %r8
        dec     %r10
        jmp     lp

    check_hex:
        find_hex_let A_BIG, A_LIT, 10
        find_hex_let B_BIG, B_LIT, 11
        find_hex_let C_BIG, C_LIT, 12
        find_hex_let D_BIG, D_LIT, 13
        find_hex_let E_BIG, E_LIT, 14
        find_hex_let F_BIG, F_LIT, 15
        1:
            jmp mult
        # ошибка, но см. коммент выше

ex:
    ret
