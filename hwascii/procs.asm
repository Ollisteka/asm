jmp main
str2dec_error db "Couldn't parse a number", "$"
mp_comb_error db "Combination of those mode and page number are illegal. Check help (/?)", "$"
mode_range_error  db "Ivalid mode number. Check help (/?)", "$"
screen_buffer dw  (80*25) dup (?)

SPACE = 20h

arg_parse proc ;arg_mask, arg_var, error
	pop bp
	pop ax
	pop bx
	test byte ptr flags, al
	jz  @@continue
	jmp bx
@@continue:
	or byte ptr flags, al
	call move_pointer
	call skip_spaces
	call str2dec
	pop bx
	mov [bx*1], al
	call check_args_consistency
	push bp
	ret
endp arg_parse

create_first_row_color proc
	push dx
	shr dx, 1
	and dx, 000Fh ;номер символа в строке
	mov byte ptr fg_color, dl
	and dl, byte ptr first_row_xor
	xor dl, byte ptr first_row_xor
	mov byte ptr bg_color, dl
	create_attribute bg_color, fg_color
	pop dx
	ret
endp create_first_row_color

print_mode_page proc
	push ax
	read_word_lowmem COLUMN_NUM_LM
	sub al, current_mp_str_len
	shr al, 1

	xor dx, dx
	mov dl, al
	
	pop ax
	mov dh, al

	mov ah, 00001111b
	mov si, offset current_mode_page_str
	call calc_address
	mov cx, current_mp_str_len

@@pr_ch:
	mov al, [si*1]
	stosw
	inc si
	loop @@pr_ch
	
	sub di, current_page_offset
	read_byte_lowmem ACTIVE_PAGE
	add al, '0'
	mov ah, 00001111b
	stosw
	
	sub di, current_mode_offset
	read_byte_lowmem DISPLAY_MODE
	add al, '0'
	mov ah, 00001111b
	stosw
	
	ret
endp print_mode_page

wait_for_key_press:
	xor ax,ax
	int 16h
	ret

hide_cursor:
	read_byte_lowmem ACTIVE_PAGE
	mov bh, al

	xor ax, ax
	mov ah, 02h

	xor dx, dx
	mov dh, 25

	int 10h
	ret

get_total_symbols_count:
	mov dh, 25
	read_word_lowmem COLUMN_NUM_LM
	mul dh ;ax - символы на странице
	ret

clear_screen proc
	call get_total_symbols_count
	mov cx, ax
	call get_video_segment
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
	; Character offset = ( row# * 80/40 + column# ) * 2 
	; Base = B800/b000 + 100h/80h * page#
	push ax bx cx si

	xor bx, bx
	read_byte_lowmem ACTIVE_PAGE
	
	cmp ax, 0
	je @@skip_add
	mov cx, ax ; cx = active page
	call get_page_size
@@add:
	add bx, ax
	loop @@add

@@skip_add:
	call get_video_segment
	add ax, bx
	mov es, ax

	read_word_lowmem COLUMN_NUM_LM
	mov bl, al
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
