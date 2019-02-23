.globl num_to_str
.include  "macro.s"

SYS_OUT  = 1
RADIX    = 10

.data
    out_buffer:	    .ascii	"                           " 
    out_buff_len =  . - out_buffer
    error_text:     .ascii  "Ошибка при переводе числа в строку!.\n"
    err_len      =  . - error_text

.text
    num_to_str:
        movq    $RADIX, %rcx
        xor     %rbx,   %rbx
        xor	    %rdx,	%rdx
        xor     %r15,   %r15

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
        mov     %rbx,   %r15

    fill_buffer:
        popq    %rax    
        cmp     $9,    %al 
        ja      error

    continue:
        add     $0x30,  %al     # чтобы печатать циферки
        stosb

        dec     %rbx
        cmp     $0,  %rbx
        jne     fill_buffer

        mov		$out_buffer, 	%rax
        mov     %r15,     %rbx    # длина
        jmp     exit

    error:
        echo error_text err_len

    exit:
        ret
