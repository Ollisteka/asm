skip_spaces:
	xor ah, ah
    mov al, [si*1]    ; letter
    mov bl, SPACE
    cmp bl, al
    je skip_char
	.ex:
    ret

    skip_char:
        inc si
        dec cx
		cmp cx, 0
		je .ex
        jmp skip_spaces