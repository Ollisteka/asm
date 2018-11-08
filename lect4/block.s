.globl  _start
.text
_start:
    add     $150,   %al  # CF если получилось больше 255
    add     $150,   %ax
    add     $150,   %eax
    add     $150,   %rax

    inc     %cl
    inc     %cx
    inc     %ecx
    inc     %rcx