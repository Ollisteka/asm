jmp main

COLUMN_NUM_LM = 044ah
ROWS_NUM_LM = 0484h

get_prev_head proc
	get_snake_coord prev_head
	ret
endp get_prev_head

get_head proc
	get_snake_coord head
	ret
endp get_head

get_tail proc
	get_snake_coord tail
	ret
endp get_tail

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

wait_for_key_press:
	xor ax,ax
	int 16h
	ret
	
hide_cursor:
	push bx dx
	xor bx, bx
	xor dx, dx
	mov dh, 1
	mov dl, 1
	call move_cursor
	pop dx bx
	ret
	
move_cursor:
; DH - row
; DL - column
	push ax
	xor ax, ax
	mov ah, 02h
	int 10h
	pop ax
	ret
	
put_char_at_coord:
; AL - ASCII code
; BL - attribute
; DH - row
; DL - column
; BH - page
	call move_cursor
	call put_char
	call hide_cursor
	ret
	
get_char_at_coord:
;RETURNS:
; AH - attribute
; AL - ASCII code
;IN:
; DH - row
; DL - column
	call move_cursor
	call get_char
	call hide_cursor
	ret
	
get_char:
	push bx
	xor ax, ax
	mov ah, 08h
	mov bh, 0
	int 10h
	pop bx
	ret
	
put_char:
;AL - ASCII code
;BL - attribute
;BH - page
	push bx cx
	;mov bh, 0 ; страница
	mov cx, 1 ; число повторений
	mov ah, 09h
	int 10h
	pop cx bx
	ret
	
reg_to_str: ;->AX
	push ax bx cx dx
    mov di, offset output
    mov cl, 4
rts1: rol ax, 4
    mov bl, al
    and bl, 0Fh          ; only low-Nibble
    add bl, 30h          ; convert to ASCII
    cmp bl, 39h          ; above 9?
    jna rts2
    add bl, 7            ; "A" to "F"
rts2: mov [di], bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz rts1              ; jump if cl is not equal 0 (zeroflag is not set)

    call_print output
	pop dx cx bx ax
    ret