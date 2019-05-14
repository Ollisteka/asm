jmp main


arrow_handler proc
	call get_prev_head
	
	cmp ah, RIGHT_ARROW
	je @@move_right
	
	cmp ah, LEFT_ARROW
	je @@move_left
	
	cmp ah, UP_ARROW
	je @@move_up
	
	cmp ah, DOWN_ARROW
	je @@move_down
	
	ret
	
@@move_right:
	inc dl
	call move_snake
	mov [direction], RIGHT_ARROW
	ret
	
@@move_left:
	dec dl
	call move_snake
	mov [direction], LEFT_ARROW
	ret
	
@@move_up:
	dec dh
	call move_snake
	mov [direction], UP_ARROW
	ret
	
@@move_down:
	inc dh
	call move_snake
	mov [direction], DOWN_ARROW
	ret
	
endp arrow_handler


move_snake proc
;DX = next coords
	cmp dl, FIELD_WIDTH-1
	je @@swap_wall
	
	cmp dl, 0
	je @@teleport_wall
	
	cmp dh, FIELD_HEIGHT-1
	je @@death_wall

@@simple:
	call remove_tail
	call move_head
	jmp @@exit
	
@@swap_wall:
	call swap
	call repaint_head_and_tail
	jmp @@exit
	
@@teleport_wall:
	mov dl, FIELD_WIDTH-2
	jmp @@simple
	
@@death_wall:
	or [flags], 10b
	jmp @@exit

@@exit:
	;mov si, [prev_head]
	;print_reg si
	;mov si, [tail]
	;print_reg si

	;call get_prev_head
	;print_reg dx
	;call get_tail
	;print_reg dx
	ret
endp move_snake

teleport proc
	ret
endp teleport


repaint_head_and_tail proc
	mov al, SNAKE_CHAR
	xor bx, bx

	call get_prev_head	
	mov bl, 0001010b
	
	call put_char_at_coord
	
	call get_tail
	mov bl, 010b
	call put_char_at_coord
	ret
endp repaint_head_and_tail


get_snake_length proc
	push bx
	mov ax, [head]
	cmp [tail], ax
	jb @@simple
		mov bx, MAX_SNAKE_LEN
		sub bx, [tail]
		add ax, bx
		jmp @@exit
@@simple:
	sub ax, [tail]
	
@@exit:
	test [flags], 1
	jz @@exit1
		mov bx, MAX_SNAKE_LEN
		sub bx, ax
		mov ax, bx

@@exit1:
	pop bx
	ret
endp get_snake_length

swap proc
	mov ax, [tail]
	mov bx, [prev_head]

	mov [prev_head], ax
	mov [tail], bx

	test [flags], 1
	jnz @@head_was_decrementing

	;;head was incrementing
	or [flags], 1
	cmp [prev_head], 0
	jne @@2
		mov [head], MAX_SNAKE_LEN-1
		jmp @@exit

	@@2:
		mov ax, [prev_head]
		dec ax
		mov [head], ax
		jmp @@exit
	
@@head_was_decrementing:
	and flags, 11111110b
	cmp [prev_head], MAX_SNAKE_LEN-1
	jne @@1
		mov [head], 0
		jmp @@exit
	
	@@1:
		mov ax, [prev_head]
		inc ax
		mov [head], ax
		jmp @@exit
	
@@exit:
	ret
endp swap

remove_tail proc
	push ax bx dx
	mov si, [tail]
	shl si, 1
	mov dx, snake[si]
	mov snake[si], 0
	
	test cx, cx
	jz @@erase_tail

	call is_intersected
	jz @@change_tail_pos
	
@@erase_tail:
	mov al, ' '
	mov bl, 0
	mov bh, 0
	call put_char_at_coord

@@change_tail_pos:
	call change_tail_pos
	pop dx bx ax
	ret
endp remove_tail

is_intersected proc
;RETURNS
;Z=1 iff intersection
;if Z=1, CX = idx of intersected cell
	;DX = tail coords
	push ax
	mov ax, dx
	mov di, offset snake
	mov cx, MAX_SNAKE_LEN
	repne scasw
	pop ax
	ret
endp is_intersected

move_head proc
;DX = next coords
	mov bh, 0
	cmp self_cross_modes, 1
	je @@self_cross_will_cut
	
	cmp self_cross_modes, 2
	je @@self_cross_is_deadly

@@move:
	mov si, [head]
	shl si, 1
	mov snake[si], dx
	mov al, SNAKE_CHAR
	mov bl, 0001010b
	call put_char_at_coord

	call get_prev_head
	mov bl, 010b
	call put_char_at_coord
	
	call change_head_pos
@@exit:
	ret
	
@@self_cross_will_cut:

	call is_intersected
	jnz @@move
	
	xor bx, bx

	@@clear_tail:
		test bx, bx
		jnz @@move
		;push bx
		push dx
		call get_tail
		mov ax, dx
		pop dx
	
		cmp dx, ax
		jne @@cont
		mov bx, 1
		@@cont:
		xor cx, cx
		call remove_tail
		;pop bx
		jmp @@clear_tail
		
	jmp @@move
	
@@self_cross_is_deadly:
	call is_intersected
	jnz @@move
	or flags, 10b
	jmp @@exit
endp move_head

change_head_pos proc
	test [flags], 1
	jz @@inc_head
		call dec_head
		ret
@@inc_head:
	call inc_head
	ret

endp change_head_pos

change_tail_pos proc
	test [flags], 1
	jz @@inc_tail
		call dec_tail
		ret
@@inc_tail:
	call inc_tail
	ret
endp change_tail_pos

inc_head proc
	push bx
	mov bx, [head]
	mov [prev_head], bx
    inc [head]
	cmp [head], MAX_SNAKE_LEN
	jb @@exit
		mov [head], 0
@@exit:
	pop bx
	ret
endp inc_head

inc_tail proc
	inc [tail]
	cmp [tail], MAX_SNAKE_LEN
	jb @@exit
		mov [tail], 0
@@exit:
	ret
endp inc_tail

dec_tail proc
	cmp [tail], 0
	je @@zero
		dec [tail]
		jmp @@exit
	@@zero:
		mov [tail], MAX_SNAKE_LEN-1
@@exit:
	ret
endp dec_tail

dec_head proc
	push bx
	mov bx, [head]
	mov [prev_head], bx
	
	cmp [head], 0
	je @@zero
		dec [head]
		jmp @@exit
	@@zero:
		mov [head], MAX_SNAKE_LEN-1
@@exit:
	pop bx
	ret
endp dec_head