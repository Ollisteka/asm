model tiny 		;все сегменты кода, данных и стека являются одним сегментом
.386 			;доступ к расширенным инструкциям

.code
ORG 100h 		;отсюда начинаются адреса нашей программы

start:
	mov		cl,		255

cmp_loop:
	;посмотреть, не надо ли выйти
	cmp 	cl,	 	0		;cl - 0
	je 		exit 			;переход, если 0 == cl
	
	;посмотреть, не надо ли напечатать точку
	cmp 	cl, 	27		;esc - стирает символ?
	je		print_dot	
	cmp 	cl, 	13		;возврат каретки
	je		print_dot	
	cmp 	cl, 	10		;newl		
	je		print_dot	
	cmp 	cl, 	9		;horizontal tab
	je		print_dot	
	cmp 	cl, 	8		;backspace
	je		print_dot
	cmp 	cl, 	7		;колокольчик, не звенит :(	
	je		print_dot
	

	;напечатать cl
	mov		dl,	  cl		;copy cl to dl
	jmp 	print_char


print_dot:
	mov		dl,	  dot  	;pointer to character
	jmp 	print_char
	

print_char:
	mov		ah, 	02h		 ;character output
	int 	21h				 ;syscall
	
	;посмотреть, не надо ли напечатать \n	
	mov 	al,		cl
	and 	al,		15
	cmp 	al, 	0
	je 		print_newl	
	
dec_and_cont:
	dec 	cl
	jmp		cmp_loop
	
	
print_newl:
	mov		dl,	  newl  		
	mov  	dx,	  offset newl	;pointer to str
	mov		ah,   PRINT_STR
	int 	SYSCALL
	jmp  	dec_and_cont
	
	
;напечатать нулевой символ и выйти
exit:
	mov		dl,	  dot  	 	 ;pointer to character
	mov		ah,   CHAR_OUTPUT
	int 	SYSCALL
	ret


dot 	db "."
newl 	db 0dh, 0ah, '$'	;CR + LF
CHAR_OUTPUT = 02h
PRINT_STR	= 09h
SYSCALL 	= 21h

end start
