model tiny
.386

.code
ORG 100h

start:
	mov		al,		33
	mov		bl,		127

cmp_loop:
	;если инкремент тут, всё работает
	inc 	al
	cmp 	bl,	 	al		;bl - al
	je 	exit 				;переход, если bl == al

;напечатать символ из al	
	mov		dl,	 	al		;copy al to dl
	;тут с инкрементом вечный цикл
	;inc 	al
	jmp 	print_char

print_char:
	mov		ah, 	02h
	int 	21h
	jmp		cmp_loop

exit:
	ret

end start
