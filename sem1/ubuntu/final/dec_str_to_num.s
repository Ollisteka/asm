
.globl	dec_str_to_num
.include "macro.s"

RADIX = 10
SPACE = 32

# args:
# %r8 - указатель на строку
# %r10 - длина строки

# returns:
# rax: десятичное число

dec_str_to_num:
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
    
    sub     $0x30,  %cl
    mul     %rbx  # ax = ax*cx 

    add     %rcx,    %rax  # rax = rax*10 + cx 

    inc     %r8
    dec     %r10
    jmp     lp

ex:
    ret
