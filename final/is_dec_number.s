.globl	_start
.include "macro.s"

#  arg1  arg2  arg3  arg4  arg5  arg6  arg7
#  rdi   rsi   rdx   r10   r8    r9    -

# returns:
# rax: 0 - число, 1 - не число
# rbx: указатель на следующий символ
# r10: оставшаяся длина строки
.text
_start:
    mov $0, %dl         # state
    # mov $example, %rsi  # str
    # mov $lexample, %r10 # length
lp:
    cmp $0, %r10 # закончилась строка, число последнее, всё плохо
    je fail

    mov $0xDEADDEAD, %eax
    mov %dl, %ah
    movb (%rsi), %al

    cmp $2, %ah # прочитали число до пробела
    je success

    mov $ls, %rcx
    mov $ss, %rdi
    repnz scasq # rdi -> offset-part
b:
    cmp $after, %rdi
    je fail

    movb (%rdi), %dl
    inc %rsi
    dec %r10

    jmp lp

fail:
    mov $1, %rax
    mov %rsi, %rbx
    ret

success:
    xor %rax, %rax
    mov $0, %al
    mov %rsi, %rbx
    ret

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cycle_numbers 0, 1
    s1: cell 1, 0, 1
        cell 1, " ", 2
        cycle_numbers 0, 1
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
