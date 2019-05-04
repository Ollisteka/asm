jmp main

SPACE = 20h
DISPLAY_MODE = 0449h
ACTIVE_PAGE = 0462h

abs_diff proc
;AX, BX
	cmp ax, bx
	jae @@ax_bigger

@@bx_bigger:
	sub bx, ax
	mov ax, bx
	ret
	
@@ax_bigger:
	sub ax, bx
	ret
	
endp abs_diff

square:
;AX
push cx
mov cl, 2
mul cl
pop cx
;Если dx != 0 : переполнение
ret


wait_for_key_press:
	xor ax,ax
	int 16h
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

check_rectangle_intersect proc
	call is_coord_on_rectangle
	jz @@exit
	
@@hit:
	mov ax, 2
    int 33h
	xor ax, ax
	call change_color
	mov al, [field_color]
	call draw_rectangle
	call draw_filled_circle
	mov ax, 1
    int 33h
	
@@exit:
	ret
endp check_rectangle_intersect

check_circle_intersect proc
	call is_coord_in_circle
	jz @@exit

@@hit:
	mov ax, 2
    int 33h

	call change_color_circle
	call draw_filled_circle
	
	
	mov ax, 1
    int 33h
	
	ret
	
@@exit:
	xor ax, ax
	ret
endp check_circle_intersect

is_coord_in_circle proc
	mov si, CIRCLE_RADIUS
	mov ax, [center_x]
	mov bx, cx
	call abs_diff
	call square
	mov cx, ax
	
	mov ax, [center_y]
	mov bx, dx
	call abs_diff
	call square
	
	add cx, ax
	
	mov ax, CIRCLE_RADIUS
	add ax, 5
	call square
	
	cmp cx, ax
	jae @@false
	
	call clear_zf
	ret
	
@@false:
	call set_zf
	ret
	

endp


is_coord_on_rectangle proc
	mov si, LINE_WIDTH*2
	mov ax, [upper_left_x]
	mov bx, [upper_left_y]

@@cmp_loop:
	cmp si, LINE_WIDTH
	jne @@cont
	add ax, FIELD_WIDTH - LINE_WIDTH
	add bx, FIELD_HEIGHT - LINE_WIDTH
	
@@cont:
	;Mouse_X-coord == Line_X-coord	
	cmp cx, ax
	je @@check_y_range

	cmp dx, bx
	je @@check_x_range
	
	inc ax
	inc bx

	dec si
	jnz @@cmp_loop

	jmp @@exit
	
@@check_x_range:
	push ax bx cx
	mov ax, [upper_left_x]
	mov bx, cx
	mov cx, ax
	add cx, FIELD_WIDTH + LINE_WIDTH
	call is_inside
	pop cx bx ax
	jz @@exit
	
	jmp @@hit
	
	
@@check_y_range:
	push ax bx cx
	mov ax, [upper_left_y]
	mov bx, dx
	mov cx, ax
	add cx, FIELD_HEIGHT + LINE_WIDTH
	call is_inside
	pop cx bx ax
	jz @@exit
	
	jmp @@hit
	
@@exit:
	call set_zf
	ret

@@hit:
	call clear_zf
	ret
endp is_coord_on_rectangle

is_inside proc
;AX = left edge
;BX = x
;CX = right edge

;ZF = 0 <=> ax <= bx <= cx
	cmp ax, bx
	ja @@false ; ax > bx
	cmp bx, cx
	ja @@false

	call clear_zf
	ret

@@false:
	call set_zf
	ret
endp is_inside

clear_zf:
	push dx
	mov dx, 1
	test dx, dx ;clear ZF
	pop dx
	ret
	
set_zf:
	push dx
	xor dx, dx
	test dx, dx ;clear ZF
	pop dx
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
	
show_cursor:
	mov ax, 1
	int 33h
	ret
	
hide_cursor:
	mov ax, 2
	int 33h
	ret