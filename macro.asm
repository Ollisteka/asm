EXIT 		= 4Ch
SYSCALL 	= 21h
PRINT_STR	= 09h

jmp main

read_byte_lowmem macro address
	mov si, address
	call read_byte_lm
endm

read_word_lowmem macro address
	mov si, address
	call read_word_lm
endm

call_save_screen_state macro
	read_byte_lowmem ACTIVE_PAGE
	push ax

	read_byte_lowmem DISPLAY_MODE
	push ax
endm

call_restore_screen_state macro
	pop ax
	mov ah, 00h
	int 10h
	
	pop ax
	mov ah, 05h
	int 10h
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

call_print macro buffer
	mov		ah,   PRINT_STR
	mov  	dx,	  offset buffer
	int 	SYSCALL
endm
