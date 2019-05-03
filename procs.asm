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
	mov si, LINE_WIDTH*2
	mov ax, [upper_left_x]
	mov bx, [upper_left_y]

@@cmp_loop:
	cmp si, LINE_WIDTH
	jne @@cont
	add ax, FIELD_WIDTH
	add bx, FIELD_HEIGHT
	
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
	cmp cx, [upper_left_x]
	jb @@exit
	
	cmp cx, [upper_left_x] + FIELD_WIDTH
	jae @@exit
	
	jmp @@hit
	
	
@@check_y_range:
	cmp dx, [upper_left_y]
	jb @@exit
	
	cmp dx, [upper_left_y] + FIELD_HEIGHT
	jae @@exit
	
	jmp @@hit
	
@@hit:
	mov ax, 2
    int 33h
	xor ax, ax
	mov al, [field_color]
	call draw_rectangle
	call change_color
	call draw_filled_circle
	mov ax, 1
    int 33h
	
@@exit:
	ret
endp check_rectangle_intersect

check_circle_intersect proc
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
	jae @@exit
	
	
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