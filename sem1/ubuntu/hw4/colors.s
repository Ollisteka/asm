.globl try_change_fg_color
.include  "macro.s"

ONE = 49
TWO = 50
THREE = 51
FOUR = 52
FIVE = 53
SIX = 54
SEVEN = 55
EIGHT = 56
NINE = 57

.data
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

.text
    try_change_fg_color:
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
        jne     return_fail
        echo    white lwhite
    return_success:
        mov    $0,  %rax
        ret

    return_fail:
        mov    $1,  %rax
        ret
