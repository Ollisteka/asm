jmp main
str2dec_error db "Couldn't parse a number", "$"
mp_comb_error db "Combination of those mode and page number are illegal. Check help (/?)", "$"
mode_range_error  db "Ivalid mode number. Check help (/?)", "$"

SPACE = 20h

print_mode_page proc
	push ax
	mov si, COLUMN_NUM_LM
	call read_word_lm
	mov byte ptr COLUMN_NUM, al
	sub al, current_mp_str_len
	shr al, 1

	xor dx, dx
	mov dl, al
	
	pop ax
	mov dh, al

	mov cx, current_mp_str_len
	mov ah, 00001111b
	mov si, offset current_mode_page_str
	nop
	call calc_address
	
@@pr_ch:
	mov al, [si*1]
	stosw
	inc si
	loop @@pr_ch
	
	sub di, current_page_offset
	mov si, ACTIVE_PAGE
	push ax
	call read_byte_lm
	add al, '0'
	mov bl, al
	pop ax
	mov al, bl
	stosw
	
	sub di, current_mode_offset
	mov si, DISPLAY_MODE
	push ax
	call read_byte_lm
	add al, '0'
	mov bl, al
	pop ax
	mov al, bl
	stosw
	
	call hide_cursor
	
	xor ax,ax
	int 16h
	
	ret
endp print_mode_page

hide_cursor:
	mov ah, 02h
	mov bh, byte ptr page_num
	xor dx, dx
	mov dh, byte ptr COLUMN_NUM
	shl dh, 2
	int 10h
	ret
	
get_total_symbols_count:
	push es
	mov ax , 0B800H
	mov es , ax
	mov dh, 25
	mov si, COLUMN_NUM_LM
	call read_word_lm
	mul dh ;ax - символы на странице
	pop es
	ret

clear_screen proc
	call get_total_symbols_count
	mov cx, ax
	mov ax, 0B800H
	push es
	mov es, ax
	xor di, di
	mov ax, 720h ; белый пробел на чёрном фоне
	rep stosw
	pop es
	ret
endp clear_screen

calc_address proc
	; input: DH = row number (0 - 24) , DL = column number (0 - 79)
	; output: ES:DI contains the required segment : offset address
	; Character offset = ( row# * 80 + column# ) * 2 = ( row# * (64 + 16) + column# ) * 2
	; Character offset = ( row# * 40 + column# ) * 2 = ( row# * (32 + 8) + column# ) * 2
	push ax bx cx si

	xor bx, bx
	mov si, ACTIVE_PAGE
	call read_byte_lm
	cmp ax, 0
	je @@cont
	mov cx, ax ; cx = active page	
	mov si, DISPLAY_MODE
	call read_byte_lm
	cmp ax, 2
	jae @@1
	mov ax, 80h
	xor bx, bx
	jmp @@add
	
@@1:
	xor bx, bx
	mov ax, 0100h
@@add:
	add bx, ax
	loop @@add
@@cont:	
	mov ax, 0B800h
	add ax, bx
	mov es, ax
	mov bl, byte ptr COLUMN_NUM
	xor ax, ax
	mov al, dh ; AX := row#
	mul bl   ; AX := row# * (80 or 40)
	mov di, ax ; DI := row# * (80 or 40)

	xor ax, ax
	mov al , dl ; AX := column#
	add di , ax ; DI := row# * 80 + column#
	shl di , 1  ; DI := ( row# * 80 + column# ) * 2
	
	
@@exit:
	pop si cx bx ax
	ret
endp calc_address

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

check_args_consistency proc
	cmp byte ptr mode_num, 1
	jbe zero_one_modes
	cmp byte ptr mode_num, 3
	jbe two_three_modes
	cmp byte ptr mode_num, 7
	je  seventh_mode
	jmp @@mode_error
	
zero_one_modes:
	cmp byte ptr page_num, 8
	jae @@error
	ret
	
two_three_modes:
	cmp byte ptr page_num, 4
	jae @@error
	ret
	
seventh_mode:
	cmp byte ptr page_num, 8
	jae @@error
	ret

@@error:
	call_print mp_comb_error
	jmp .ex_it
	
@@mode_error:
	call_print mode_range_error
	jmp .ex_it	
	
endp check_args_consistency

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
