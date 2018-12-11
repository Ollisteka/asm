.globl copy_str

# args:
# rdi - dest
# rsi - source
# rcx - lsource
# returns:
# rax - new dest offset

.text
copy_str:
    movb (%rsi), %al
    stosb
    inc %rsi
    dec %rcx
    jnz copy_str
    mov %rdi, %rax
    ret
