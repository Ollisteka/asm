.globl _start

EXIT 	 = 60
READ 	 = 0
WRITE 	 = 1
OPEN 	 = 2
CLOSE 	 = 3
SYS_IN   = 0
SYS_OUT  = 1
MINUS 	 = 45

.data
    hwmsg:	    .ascii	"Hello, world!\n"
    hwlen = . - hwmsg
	fname: 		.ascii "new.txt"
	from:		.ascii "f"      # al
	count:		.ascii "c"      # ah
	input:		.ascii "i"      # bl
	output:		.ascii "o"      # bh
    error_text:     .ascii  "Неправильные аргументы!\n"
    err_len      =  . - error_text

.text
_start:

    pop     %rdi    # тут число аргументов
    cmp     $7,     %rdi
    jb      error
	# если аргументов меньше чем 7 или больше чем 9 - брось ошибку
	pop     %rdi    # тут имя файла
read_args:
	pop 	%rdi

    cmp		$0,		%rdi
	je		prog

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
    xor     %rcx, %rcx
	pop 	%rdi
    mov     %al,  %cl
    mov     %rdi, %rax
    mov     %cl,   %al
	jmp read_args

read_count:
    xor     %rcx, %rcx
	pop 	%rdi
    mov     %ah,  %cl
    mov     %rdi, %rax
    mov     %cl,   %ah
	jmp read_args

read_in:
    xor     %rcx, %rcx
	pop 	%rdi
    mov     %bl,  %cl
    mov     %rdi, %rbx
    mov     %cl,  %bl
	jmp read_args

read_out:
    xor     %rcx, %rcx
	pop 	%rdi
    mov     %bh,  %cl
    mov     %rdi, %rbx
    mov     %cl,  %bh
	jmp read_args


    mov     $fname, %rdi
    mov     $101,   %rsi        # write only
    mov     $OPEN,  %rax
    syscall # fd -> rax
    push    %rax

    mov     %rax,   %rdi
    mov     $hwmsg, %rsi
    mov     $hwlen, %rdx
    mov     $WRITE,     %rax
    syscall

    pop 	%rdi
    mov 	$CLOSE, %rax
	syscall
	
prog:
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
