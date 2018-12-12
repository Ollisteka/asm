.globl	_start

.macro cell state, char, dest 
    .ascii "\char"
    .byte \state
    .word 0xDEAD, 0x00, 0x00
    .byte \dest, 0
    .word 0xFFFF, 0xFFFF, 0xFFFF
.endm

#  arg1  arg2  arg3  arg4  arg5  arg6  arg7
#  rdi   rsi   rdx   r10   r8    r9    -
.text
_start:
    mov $0, %dl         # state
    mov $example, %rsi  # str
    mov $lexample, %r10 # length
lp:
    cmp $0, %r10
    je ex

    mov $0xDEADDEAD, %eax
    mov %dl, %ah
    movb (%rsi), %al

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
ex:
    add $48, %dl
    movb %dl, result
    jmp print

fail:
    jmp print

print:
    mov $1, %rax
    mov $1, %rdi
    mov $result, %rsi
    mov $2, %rdx
    syscall

    mov	$60, %rax
	syscall

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cell 0, "a", 1
    s1: cell 1, "b", 1
    # ls = 6 # 3*2
    ls = (. - ss) / 8
    after: .word 0, 0, 0, 0

    example: .ascii "1"
    lexample = . - example

    result: .ascii "F\n"



