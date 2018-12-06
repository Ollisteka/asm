.nolist

.data
	clear:  .ascii "\x1B[H\x1B[J"
	lclear = . - clear

.macro  read_char reg buff
    mov		$0, 	    %rax
	mov		\reg,   	%rdi
    mov		$\buff, 	%rsi
	mov		$1,	        %rdx
    syscall # кол-во прочитанных символов -> rax
.endm

.macro  open fname flag
    mov     \fname,  %rdi
    mov     \flag,   %rsi
    mov     $2,      %rax
    syscall # fd -> rax
.endm

.macro	close  fd
	mov     \fd, 	%rdi
    mov 	$3,     %rax
	syscall
.endm

.macro  print  fd str len=1
	mov 		$1,    %rax
	mov 		\fd,  %rdi
	mov 		$\str, %rsi
	mov 		$\len, %rdx
	syscall
.endm

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

