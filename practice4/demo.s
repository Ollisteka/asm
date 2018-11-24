.globl main
.include  "macro.s"

ESC = 27
SPACE = 32
S_LIT = 115
W_LIT = 119
A_LIT = 97
D_LIT = 100

.data
    clear:  .ascii "\x1B[H\x1B[J"
    lclear = . - clear
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
    hide_cursor: .ascii "\x1B[?25l"
    lhide_cursor = . - hide_cursor
    show_cursor: .ascii  "\x1B[?25h"
    lshow_cursor = . - show_cursor
    yellow: .ascii "\x1B[33m"
    lyellow = . - yellow
    # "\x1B[n;mH"  n - строка, m - столбец

.text
    main:
    echo hide_cursor lhide_cursor
    echo clear lclear
    echo yellow lyellow

move:
    echo xchar
    call    getch

    push    %rax
    echo    cback lcback
    pop     %rax

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

center:


1:    
    jmp     move

ex:
    echo clear lclear
    echo show_cursor lshow_cursor
    mov $60,    %rax
    syscall
