.globl _start
.include  "macro.s"

EXIT 	 = 60
OPEN 	 = 2
SYS_IN   = 0
SYS_OUT  = 1
MINUS 	 = 45
READONLY = 0
WRITE_OR_CREATE = 101

.data
	from:		.ascii "f"      # r8
	count:		.ascii "c"      # r9
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

    mov     from,  %cl
	cmpb	%cl, (%rdi)
    je 		read_from

    mov     count,  %cl
	cmpb	%cl, (%rdi)
    je 		read_count

    jmp     error

read_from:    
	pop 	%rsi   
    call parse_num  # записывает число в rax   
    mov     %rax,   %r8
	jmp read_args

read_count:
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
     
    add     %r8,    %r9   # finish = from + count
    push	%r11
    open    %r10    $READONLY
    mov     %rax,   %r12
    pop 	%r11

    cmp     $0,     %r11  # check output
    jne     print_to_file

print_to_console:
    mov		$SYS_OUT, 	%r14
    xor     %rcx,       %rcx
    jmp     skip_loop

print_to_file:
    open    %r11    $WRITE_OR_CREATE
    mov     %rax,   %r14
    xor     %rcx,   %rcx

skip_loop:
    cmp     %rcx,   %r8
    je      write_loop

    push    %rcx
    read_char   %r12    buffer
    cmp     $0,      %rax
    je      close_files 

    pop     %rcx
    inc     %rcx
    jmp     skip_loop

write_loop:
    cmp     %rcx,   %r9
    je      close_files

read:    
    push        %rcx
    read_char   %r12  buffer   # в rax - количество прочитанных символов   
    
    cmp     $0,      %rax
    je      close_files 
    
    print   %r14    buffer
    pop     %rcx
    inc     %rcx
    jmp     write_loop

close_files:
    close     %r12

    cmp     $0,     %r11
    jne     close_output
    jmp     exit

close_output:
    close    %r14
    jmp     exit

error:
    print $SYS_OUT error_text err_len

exit:
    movq    $EXIT,  %rax
	syscall
