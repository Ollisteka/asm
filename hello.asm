hello_rsd:
	hello  db 'Hello, ASM!', '$'
	push 	ax
	mov		ah,   PRINT_STR
	mov  	dx,	  offset hello	;pointer to str
	int 	SYSCALL
	pop 	ax
	
	ret