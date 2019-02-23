.globl print_num
.include  "macro.s"

NUM  		= 15
BASE        = 10
MINUS       = 45

.data
    buffer:	  .skip  32
    newl:     .ascii "\n"
    buff_len  = . - buffer

.text
print_num:
    # args:
    # $NUM,   %rax    
    movq    $buffer,    %rdi
    movq    $BASE,  %rcx
    xor     %rbx,   %rbx
    xor	    %rdx,	%rdx

    cmp $0, %rax
	jge divide_loop

    neg %rax

    push %rax
    mov $MINUS, %al
	stosb
    pop %rax

divide_loop:
# rax = rax / rcx
# rdx = rax % rcx
    div     %rcx
    push    %rdx
    xor	    %rdx,	%rdx
    inc     %rbx
    cmp     $0,     %rax
    jne     divide_loop


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

	echo    buffer, buff_len
    ret
