jmp main

str2dec_error db "Couldn't parse a number", "$"

SPACE = 20h
DISPLAY_MODE = 0449h
ACTIVE_PAGE = 0462h

wait_for_key_press:
	xor ax,ax
	int 16h
	ret


get_page_size:
	read_byte_lowmem DISPLAY_MODE
	cmp ax, 2
	jae @@big_pages
		mov ax, 80h
		ret
	
	@@big_pages:
		mov ax, 0100h
		ret


get_video_segment:
	read_byte_lowmem DISPLAY_MODE
	cmp al, 7
	je @@seventh_mode
		mov ax, 0B800h
		ret
	@@seventh_mode:
		mov ax, 0B000h
		ret

read_byte_lm proc
	push es
	push 0
	pop es
	mov al, byte ptr es:si
	xor ah, ah
	pop es
	ret
endp read_byte_lm

read_word_lm proc
	;returns ax - word
	push es
	push 0
	pop es
	mov ax, word ptr es:si
	pop es
	ret
endp read_word_lm


str2dec proc ;input: si
	push bx dx
    xor  ax, ax
	xor  dx, dx
	mov  dl, 10

.str2dec_loop:
	cmp cx, 0
	je  @@ret
    mov bl, [si*1]
	cmp bl, SPACE
	je 	@@ret
	cmp bl, '/'
	je 	@@ret
    sub bl, '0'
    cmp bl, 10
    jnb @@error

    mul dl
    add ax, bx
    call move_pointer
    jmp .str2dec_loop
	
@@error:
	call_print str2dec_error
	call_exit
 
@@ret:
    pop dx bx

	ret

endp str2dec	

move_pointer:
	inc si
	dec cx
	ret
	

skip_spaces:
	cmp cx, 0
	je .ex
	xor ah, ah
    mov al, [si*1]    ; letter
    mov bl, SPACE
    cmp bl, al
    je skip_char
	.ex:
    ret

    skip_char:
        call move_pointer
		cmp cx, 0
		je .ex
        jmp skip_spaces
