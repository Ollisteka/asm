PRINT_STR	= 09h
WRITE 		= 40h ;bx - file handler, cx - length, dx - buffer. ax - len\error
EXIT 		= 4Ch
STDOUT 		= 1
SYSCALL 	= 21h

jmp main

read_byte_lowmem macro address
	mov si, address
	call read_byte_lm
endm

read_word_lowmem macro address
	mov si, address
	call read_word_lm
endm

call_print macro buffer
	mov		ah,   PRINT_STR
	mov  	dx,	  offset buffer
	int 	SYSCALL
endm

call_exit macro
	mov ah, EXIT
    int SYSCALL
endm

print_reg macro reg
	push ax
	mov ax, reg
	call reg_to_str
	pop ax
endm 
