.globl _start
.include  "macro.s"

EXIT 	 = 60
SYS_IN   = 0
SYS_OUT  = 1
MINUS 	 = 45
READONLY = 0
WRITE_OR_CREATE = 101

.data
	key:		.ascii "k"      # r9
	input:		.ascii "i"      # r10
	output:		.ascii "o"      # r11
    error_text:     .ascii  "Неправильные аргументы!\n"
    err_len      =  . - error_text
    buffer:	    .ascii	" "

.text
_start:
    pop     %rdi    # тут число аргументов
    cmp     $7,     %rdi
    jb      error
	pop     %rdi    # тут имя файла

read_args:
	pop 	%rdi

    cmp		$0,		%rdi
	je		main

	cmpb	$MINUS, (%rdi)
	je 		parse_flag

    jmp     error

parse_flag:
    inc     %rdi
    mov     output,  %cl
	cmpb	%cl, (%rdi)
    je 		read_out

    mov     input,  %cl
	cmpb	%cl, (%rdi)
    je 		read_in

    mov     key,  %cl
	cmpb	%cl, (%rdi)
    je 		read_key

    jmp     error

read_key:
   	pop 	%rsi    
    call parse_num   # записывает число в rax   
    mov     %rax,   %r9
	jmp read_args

read_in:
	pop 	%r10
	jmp read_args

read_out:
	pop 	%r11
	jmp read_args

main:
    cmp     $0,     %r10  # check input
    je      error

    cmp     $0,     %r11  # check output
    je      error 

    push	%r11
    open    %r10    $READONLY
    mov     %rax,   %r12
    pop 	%r11

    open    %r11    $WRITE_OR_CREATE
    mov     %rax,   %r14
    xor     %rcx,   %rcx

    movq    $buffer,    %rdi

xor_loop:
    read_char   %r12    buffer
    cmp     $0,      %rax
    je      close_files 

    mov     buffer,  %rax
    xor     %r9,      %rax

debug:
    movb    %al,  buffer
    print   %r14   buffer
    jmp     xor_loop

close_files:
    close    %r12
    close    %r14
    jmp     exit

error:
    print $SYS_OUT error_text err_len

exit:
    movq    $EXIT,  %rax
	syscall
