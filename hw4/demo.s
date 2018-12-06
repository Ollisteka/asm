.globl main
.include  "macro.s"

ESC = 27
SPACE = 32
S_LIT = 115
W_LIT = 119
A_LIT = 97
D_LIT = 100

.text
main:
    hide_cursor
    cls
    xor   %r14, %r14    # сюда буду класть максимальную колонку
    xor   %r15, %r15    # текущая колонка 
    mov   $1,   %r15

move:
    echo    xchar
    call    getch

    push    %rax
    # посмотреть, а не в последней ли мы колонке
    call    cheight
    mov     %rax,   %r14
    cmp     %r14,   %r15
    je      last_column
    echo    cback lcback
    pop     %rax
    jmp     compare

last_column:
    echo    cbackcol lcbackcol
    pop     %rax

compare:
    cmp     $ESC,    %al
    je      ex

    cmp     $SPACE,    %al
    je      center

    cmp     $S_LIT,   %al
    jne     1f
    echo    cdown lcdown

1:
    cmp     $W_LIT,   %al
    jne     1f
    echo    cup lcup

1:
    cmp     $A_LIT,   %al
    jne     1f
    cmp     $1,   %r15
    je      1f
    dec     %r15
    echo    cleft lcleft

1:
    cmp     $D_LIT,   %al
    jne     1f
    cmp     %r14,   %r15   # уже на краю экрана
    je      re
    inc     %r15
    echo    cright lcright
    jmp     1f
re:
    echo    cback lcback
    echo    cright lcright

1:
    call    try_change_fg_color
    jmp     1f

center:    
    movq    $buffer,    %rdi

    append  $esc_seq $lesc_seq

    push    %rdi
    get_half_of cwdith
    pop    %rdi
    append %rax %rbx

    append $semicolon

    push    %rdi
    get_half_of cheight
    pop    %rdi
    append %rax %rbx

    append $h_big

    echo    buffer  lbuffer
    call    cheight
    shr     %rax
    mov     %rax,   %r15

1:    
    jmp     move

ex:
    cls
    show_cursor
    exit


.data
    xchar:  .ascii "x"
    schar:  .ascii " "
    cback:  .ascii "\x1B[D \x1B[D"
    lcback = . - cback
    cbackcol: .ascii "\x1B[D  "
    lcbackcol = . - cbackcol
    cdown:  .ascii "\x1B[B"
    lcdown = . - cdown
    cup:  .ascii "\x1B[A"
    lcup = . - cup
    cleft: .ascii "\x1B[D"
    lcleft = . - cleft
    cright: .ascii "\x1B[C"
    lcright = . - cright
    esc_seq: .ascii "\x1B["
    lesc_seq = . - esc_seq
    semicolon: .ascii ";"
    h_big: .ascii "H"
    buffer: .ascii "           " # "\x1B[n;mH"  n - строка, m - столбец
    lbuffer = . - buffer
    