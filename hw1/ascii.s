.global _start

EXIT 	 = 60
WRITE 	 = 1
SYS_OUT  = 1
SYMB_LEN = 1

.text
_start:
	mov		$dot,  		%rsi
	mov		$WRITE,     %rax
	mov		$SYS_OUT, 	%rdi
	mov		$SYMB_LEN,	%rdx
	syscall

	mov		$1,	%bl
	mov		$1, %bh
	
cmp_loop:
	cmp		$255,	%bl
	je		exit
	
	cmp		$32,	%bl
	jb		print_dot

	movb 	%bl,	 a
    mov		$a, 	%rsi
    jmp		print_char
    
print_dot:
	mov		$dot, 	%rsi

print_char:
    mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi
	mov		$SYMB_LEN,	%rdx
	syscall
	
	inc   	%bh
	cmp		$16,		%bh
	je		print_newl
	
dec_and_cont:
	inc		%bl
	jmp 	cmp_loop
	
print_newl:
	mov		$0,			%bh
	mov		$new_line, 	%rsi
	mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi 
	mov		$SYMB_LEN,	%rdx 
	syscall

	jmp 	dec_and_cont

exit:
	movb 	%bl,	 a
	mov		$a, 	%rsi	
    mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi
	mov		$SYMB_LEN,	%rdx
	syscall

	mov		$new_line, 	%rsi
	syscall
	
    movq	$EXIT, %rax
	syscall
	
.data
	a:			.ascii	"."
	dot: 		.ascii	"."
	new_line:	.ascii	"\n"
