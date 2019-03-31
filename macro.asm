PRINT_STR	= 09h
WRITE 		= 40h ;bx - file handler, cx - length, dx - buffer. ax - len\error
EXIT 		= 4Ch
STDOUT 		= 1
GIVE_VECTOR = 35h
SYSCALL 	= 21h
RSD_NUM_STATUS = 0
RSD_INSTALLED = 0FFh

jmp main

read_byte_lowmem macro address
	mov si, address
	call read_byte_lm
endm

read_word_lowmem macro address
	mov si, address
	call read_word_lm
endm

create_attribute macro background_color, foreground_color
	; attribute = blink_bit + background_color + foreground_color
	xor ah, ah
	mov ah, 0
	shl ah, 3
	or ah, byte ptr background_color
	shl ah, 4
	or ah, byte ptr foreground_color 
endm

jmp_if_bit_set macro mask, label
    test byte ptr flags, mask
	jnz  label ; прыгнем, если бит установлен
endm

jmp_if_bit_not_set macro mask, label
    test byte ptr flags, mask
	jz  label ; прыгнем, если бит НЕ установлен
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

call_arg_parse macro arg_mask, arg_var
	jmp_if_bit_set arg_mask, .double_arg_error
	or byte ptr flags, arg_mask
	call move_pointer
	call skip_spaces
	call str2dec
	mov byte ptr arg_var, al
	mov al, byte ptr arg_var
	call check_args_consistency
endm