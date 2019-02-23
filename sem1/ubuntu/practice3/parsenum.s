.globl parse_num
.include  "macro.s"

EXIT 	 = 60
SYS_OUT  = 1
RADIX    = 10
ZERO     = 0x30
NINE     = 0x39

.data
    error_text:     .ascii  "В регистре rsi лежит не число! :(.\n"
    err_len      =  . - error_text

.text
parse_num:
    xor     %ax,    %ax
    xor     %bx,    %bx
    xor     %cx,    %cx

parse_num_inner:   
    movb    (%rsi), %bl
    cmp     $0,  %bl
    je      success

    # проверяю, что это действительно циферки
    cmp     $ZERO,  %bl
    jb      error
    cmp     $NINE,  %bl
    ja      error
    
    sub     $0x30,  %bl
    mov     $RADIX, %dx
    mul     %dx
    add     %bx,    %ax
    inc     %rsi
    jmp     parse_num_inner

error:
    print $SYS_OUT error_text err_len

exit:
    movq    $EXIT,  %rax
	syscall

success:
    # в rax - чиселка
    ret
