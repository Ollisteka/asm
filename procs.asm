jmp main
str2dec_error db "Couldn't parse a number", "$"
mp_comb_error db "Combination of those mode and page number are illegal. Check help (/?)", "$"
mode_range_error  db "Ivalid mode number. Check help (/?)", "$"

SPACE = 20h

calc_address proc
	; input: DH = row number (0 - 24) , DL = column number (0 - 79)
	; output: ES:DI contains the required segment : offset address
	; Character offset = ( row# * 80 + column# ) * 2 = ( row# * (64 + 16) + column# ) * 2
	; Character offset = ( row# * 40 + column# ) * 2 = ( row# * (32 + 8) + column# ) * 2
	push ax bx
	mov bl, byte ptr COLUMN_NUM
	mov ax, 0B800h
	mov es, ax
	xor ax, ax
	mov al, dh ; AX := row#
	shl ax, 3  ; AX := row# * 8
	cmp bl, 40
	je @@1
	shl ax, 1  ; AX := row# * 16
@@1:
	mov di, ax
	shl ax, 1  ; AX := row# * 32
	cmp bl, 40
	je @@2
	shl ax, 1  ; AX := row# * 64
@@2:
	add di, ax ; DI := row# * (80 or 40)
	xor ax, ax
	mov al , dl ; AX := column#
	add di , ax ; DI := row# * 80 + column#
	shl di , 1  ; DI := ( row# * 80 + column# ) * 2
	pop bx ax
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
