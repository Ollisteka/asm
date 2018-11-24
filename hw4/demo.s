.globl main
.include  "macro.s"

ESC = 27
SPACE = 32
S_LIT = 115
W_LIT = 119
A_LIT = 97
D_LIT = 100
ONE = 49
TWO = 50
THREE = 51
FOUR = 52
FIVE = 53
SIX = 54
SEVEN = 55
EIGHT = 56
NINE = 57
Q_LIT = 113

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
    black: .ascii "\x1B[30m"
    lblack = . - black
    red: .ascii "\x1B[31m"
    lred = . - red
    green: .ascii "\x1B[32m"
    lgreen = . - green
    yellow: .ascii "\x1B[33m"
    lyellow = . - yellow
    blue: .ascii "\x1B[34m"
    lblue = . - blue
    magenta: .ascii "\x1B[35m"
    lmagenta = . - magenta
    cyan: .ascii "\x1B[36m"
    lcyan = . - cyan
    white: .ascii "\x1B[37m"
    lwhite = . - white
    # "\x1B[n;mH"  n - строка, m - столбец

.text
    main:
    echo hide_cursor lhide_cursor
    echo clear lclear
   # echo yellow lyellow

move:
    echo xchar
    call    getch

    push    %rax
    echo    cback lcback
    pop     %rax

    cmp     $ESC,    %al
    je      ex
   # cmp     $SPACE,    %al
   # je      center

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
    cmp     $ONE,    %al
    jne     1f
    echo    black lblack

1:
    cmp     $TWO,    %al
    jne     1f
    echo    red lred

1:
    cmp     $THREE,    %al
    jne     1f
    echo    green lgreen
    
1:
    cmp     $FOUR,    %al
    jne     1f
    echo    yellow lyellow

1:
    cmp     $FIVE,    %al
    jne     1f
    echo    blue lblue

1:
    cmp     $SIX,    %al
    jne     1f
    echo    magenta lmagenta

1:
    cmp     $SEVEN,    %al
    jne     1f
    echo    cyan lcyan
    
1:
    cmp     $EIGHT,    %al
    jne     1f
    echo    white lwhite

1:    
    jmp     move

ex:
    echo clear lclear
    echo show_cursor lshow_cursor
    mov $60,    %rax
    syscall
