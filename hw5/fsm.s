.globl _start
.include  "macro.s"

.macro cell state, char, dest 
    .ascii "\char"
    .byte \state
    .word 0xDEAD, 0x00, 0x00
    .byte \dest, 0
    .word 0xFFFF, 0xFFFF, 0xFFFF
.endm

PROTOCOL = 2
HOST = 7 # HOST = 0, 6, 7, если неравно, то сохрани
        # PORT = 8, 9, если неравно, то сохрани
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
    mov %dl, %ah        # source
    movb (%rsi), %al    # letter

b2:
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
    cmp $7,  %dl
    je  success
    cmp $9,  %dl
    je  success
    cmp $10,  %dl
    je  success
    cmp $11,  %dl
    je  success
    cmp $12,  %dl
    je  success
    cmp $14,  %dl
    je  success
    cmp $15,  %dl
    je  success
    jmp fail

success:
    xor  %rax, %rax
    mov  %dl,   %al
    call num_to_str
    movq $result, %rdi
    append %rax %rbx
    jmp print

fail:
    echo invalid linvalid
    exit

print:
    echo result 3
    exit

.data
    ss: .word 0, 0, 0, 0, 0, 0, 0, 0
    s0: cell 0, "a", 1
    s1: cell 1, "a", 1
        cell 1, ":", 2
        cell 1, ".", 6
    s2: cell 2, "/", 3
    s3: cell 3, "/", 4
    s4: cell 4, "a", 5
    s5: cell 5, "a", 5
        cell 5, ".", 6
    s6: cell 6, "a", 7
    s7: cell 7, "a", 7
        cell 7, ":", 8
        cell 7, ".", 6
        cell 7, "/", 10
        cell 7, "?", 12
        cell 7, "#", 15
    s8: cell 8, "0", 9
    s9: cell 9, "0", 9
        cell 9, "/", 10
        cell 9, "?", 12
        cell 9, "#", 15
    s10: cell 10, "a", 11
    s11: cell 11, "a", 11
         cell 11, "/", 10
         cell 11, "?", 12
         cell 11, "#", 15
    s12: cell 12, "a", 13
    s13: cell 13, "a", 13
         cell 13, "=", 14
    s14: cell 14, "a", 14
         cell 14, "&", 12
         cell 14, "#", 15
    s15: cell 15, "a", 15
         cell 15, "#", 99
         cell 15, "&", 99
    s99: cell 99, "a", 99
    ls = . - ss
    after: .word 0, 0, 0, 0

    example: .ascii "aa.a?a="
    lexample = . - example

    result: .ascii "  \n"

    invalid: .ascii "INVALID_URL\n"
    linvalid = . - invalid
    