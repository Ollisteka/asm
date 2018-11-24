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

move:
    echo xchar
    call    getch

    push    %rax
    echo    cback lcback
    pop     %rax
d:
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
    echo    cleft lcleft

1:
    cmp     $D_LIT,   %al
    jne     1f
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
    