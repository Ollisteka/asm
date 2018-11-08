.globl _start

EXIT 	 = 60
READ 	 = 0
WRITE 	 = 1
SYS_IN   = 0
SYS_OUT  = 1
MULT 	 = 42
PLUS     = 43
MINUS 	 = 45
DIVIDE 	 = 47
NEW_LINE = 10
RADIX    = 10
ZERO     = 0x30
NINE     = 0x39

.data
    in_buffer:	    .ascii	"                              "
    in_buffer_len = . - in_buffer
    out_buffer:	    .ascii	"                           \n" 
    out_buff_len =  . - out_buffer
    error_text:     .ascii  "Входная строка имеет неверный формат.\n"
    err_len      =  . - error_text

.text
_start:
    mov		$READ, 	    %rax
	mov		$SYS_IN, 	%rdi
    mov		$in_buffer, 	%rsi
	mov		$in_buffer_len,	%rdx
    syscall
    # в rax - количество прочитанных символов 
    xor     %ax,    %ax
    xor     %bx,    %bx
    xor     %cx,    %cx   

parse_first_op:
    mov     $RADIX, %dx
    movb    (%rsi), %bl
    cmp     $PLUS,  %bl
    je      skip_op
    cmp     $MINUS,  %bl
    je      skip_op
    cmp     $MULT,  %bl
    je      skip_op
    cmp     $DIVIDE,  %bl
    je      skip_op
    # проверяю, что это действительно циферки
    cmp     $ZERO,  %bl
    jb      error
    cmp     $NINE,  %bl
    ja      error
    
    sub     $0x30,  %bl
    mul     %dx
    add     %bx,    %ax
    inc     %rsi
    jmp     parse_first_op

skip_op:
    movb    (%rsi), %bl
    push    %rbx
    inc     %rsi
    xor     %rcx,   %rcx
    mov     %ax,    %cx
    xor     %ax,    %ax

parse_sec_op:
    mov     $RADIX, %dx
    movb    (%rsi), %bl
    cmp     $NEW_LINE,  %bl
    je      exec
    # проверяю, что это действительно циферки
    cmp     $ZERO,  %bl
    jb      error
    cmp     $NINE,  %bl
    ja      error

    sub     $0x30,  %bl
    mul     %dx
    add     %bx,    %ax
    inc     %rsi
    jmp parse_sec_op

exec:
    pop     %rbx

    cmp     $PLUS,  %bl
    je      add_op
    cmp     $MINUS,  %bl
    je      sub_op
    cmp     $MULT,  %bl
    je      mul_op
    cmp     $DIVIDE,  %bl
    je      div_op
    jmp     error

add_op:  
    add     %cx,    %ax  # в ax ответ
    jmp     get_ready

sub_op:   
    sub     %ax,    %cx
    mov     %cx,    %ax
    jmp     get_ready

mul_op:
    mul     %rcx
    jmp     get_ready

div_op:
    xor	    %rdx,	%rdx
    push    %rax
    mov     %rcx,   %rax
    pop     %rcx
    div     %rcx
    jmp     get_ready

get_ready:
    movq    $RADIX, %rcx
    xor     %rbx,   %rbx
    xor	    %rdx,	%rdx

divide_loop:
# rax = rax / rcx
# rdx = rax % rcx
    div     %rcx
    push    %rdx
    xor	    %rdx,	%rdx
    inc     %rbx
    cmp     $0,     %rax
    jne     divide_loop

    movq    $out_buffer,    %rdi

fill_buffer:
    popq    %rax    
    cmp     $9,    %al 
    jbe     continue
    add     $7,     %al     # чтобы печатать ABCDEF

continue:
    add     $0x30,  %al     # чтобы печатать циферки
    stosb

    dec     %rbx
    cmp     $0,  %rbx
    jne     fill_buffer

	mov		$out_buffer, 	%rsi	
    mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi
	mov		$out_buff_len,	%rdx
	syscall

    jmp     exit

error:
    mov		$error_text, 	%rsi	
    mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi
	mov		$err_len,	%rdx
	syscall

exit:
    movq    $EXIT,  %rax
	syscall
