.nolist

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

