.globl _start

NUM  		= 15
BASE        = 2

EXIT 	 = 60
WRITE 	 = 1
SYS_OUT  = 1

.data
    buffer:	    .ascii	"                              \n" 
    buff_len  = . - buffer

.text
_start:
    movq    $NUM,   %rax    
    movq    $BASE,  %rcx
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

    movq    $buffer,    %rdi

fill_buffer:
    popq    %rax    
    cmp     $9,     %al 
    jbe     continue        # al <= 9
    add     $7,     %al     # чтобы печатать ABCDEF

continue:
    add     $0x30,  %al     # чтобы печатать циферки
    stosb

    dec     %rbx
    cmp     $0,  %rbx
    jne     fill_buffer

	mov		$buffer, 	%rsi	
    mov		$WRITE, 	%rax
	mov		$SYS_OUT, 	%rdi
	mov		$buff_len,	%rdx
	syscall

    movq    $EXIT,  %rax
	syscall
