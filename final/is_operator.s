.globl	is_operator
.include "macro.s"

#  arg1  arg2  arg3  arg4  arg5  arg6  arg7
#  rdi   rsi   rdx   r10   r8    r9    -

# returns:
# rax: 0 - число, 1 - не число
# rbx: указатель на следующий символ
# r10: оставшаяся длина строки
.text
is_operator:
    mov $0, %dl         # state
    # mov $example, %rsi  # str
    # mov $lexample, %r10 # length
lp:
    cmp $0, %r10
    je success

    mov $0xDEADDEAD, %eax
    mov %dl, %ah
    movb (%rsi), %al

    cmp $99, %ah # прочитали до пробела
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
    s1: cell 1, " ", 99
    s2: cell 2, " ", 99
    s3: cell 3, " ", 99
    s4: cell 4, " ", 99
    s5: cell 5, " ", 99
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0
