model tiny 		;все сегменты кода,данных и стека являются одним сегментом
.386 			;доступ к расширенным инструкциям

.code
ORG 100h 		;отсюда начинаются адреса нашей программы

start:
	;print
	push cs
	pop ds 					 ; записали в регистр данных регистр кода   		 
    mov  ah, 9      		 ; ah=9 - "print string" sub-function
	mov  dx, offset msg      ; 
	int 21h					 ;syscall

	;exit
	ret
	
msg	db	"Hello$"  	;db - типа данных, по байту на символ

end start