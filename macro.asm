PRINT_STR	= 09h
EXIT 		= 4Ch
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
