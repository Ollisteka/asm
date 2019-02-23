.nolist

.data
	clear:  .ascii "\x1B[H\x1B[J"
	lclear = . - clear

.macro  echo   str len=1
	mov 		$1,    %rax
	mov 		$1,  %rdi
	mov 		$\str, %rsi
	mov 		$\len, %rdx
	syscall
.endm

.macro  append   str len=$1
    mov     \str,   %rsi
    mov     \len, %rcx
    rep movsb
.endm

.macro  get_half_of  func
    call    \func
    shr     %rax
    call    num_to_str
.endm

.macro cls
	echo clear lclear
.endm

.macro hide_cursor
	.data
		hide_cursor: .ascii "\x1B[?25l"
    	lhide_cursor = . - hide_cursor
	.text
		echo hide_cursor lhide_cursor
.endm

.macro show_cursor
	.data
		show_cursor: .ascii  "\x1B[?25h"
    	lshow_cursor = . - show_cursor
	.text
		echo show_cursor lshow_cursor
.endm

.macro exit
	mov $60,    %rax
    syscall
.endm

