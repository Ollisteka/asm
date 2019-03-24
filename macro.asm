PRINT_STR	= 09h
WRITE 		= 40h ;bx - file handler, cx - length, dx - buffer. ax - len\error
EXIT 		= 4Ch
STDOUT 		= 1
GIVE_VECTOR = 35h
SYSCALL 	= 21h
RSD_NUM_STATUS = 0
RSD_INSTALLED = 0FFh

jmp main

create_attribute macro background_color, foreground_color
	; attribute = blink_bit + foreground_color + bright_bit + background_color
	xor bl, bl
	mov bl, 0
	shl bl, 3
	or bl, byte ptr background_color
	shl bl, 4
	or bl, byte ptr foreground_color 
endm

jmp_if_bit_set macro mask, label
    test byte ptr flags, mask
	jnz  label ; прыгнем, если бит установлен
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