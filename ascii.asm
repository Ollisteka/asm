model tiny 		;все сегменты кода,данных и стека являются одним сегментом
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
	cmp 	cl, 	32		
	jb		print_dot		;cl < 32

	;напечатать cl
	mov		dl,	  cl		;copy cl to dl
	jmp 	print_char


print_dot:
	mov		dl,	  unprt  	;pointer to character
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
	mov		ah, 	09h		 	;print str
	int 	21h				 	;syscall
	jmp  	dec_and_cont
	
	
;напечатать нулевой символ и выйти
exit:
	mov		dl,	  unprt  	 ;pointer to character
	mov		ah, 	02h		 ;character output
	int 	21h				 ;syscall
	ret


unprt 	db "."
newl 	db 0dh, 0ah, '$'

end start
