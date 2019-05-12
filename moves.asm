jmp main

move_snake proc
;DX = next coords
;check for swap wall
	cmp dl, FIELD_WIDTH-1
	je @@swap_wall

	call remove_tail
	call move_head
	jmp @@exit
	
@@swap_wall:
	call swap
	call repaint_head_and_tail
	jmp @@exit

@@exit:
	ret
endp move_snake


repaint_head_and_tail proc
	mov al, '*';178
	mov bx, [prev_head]
	shl bx, 1
	mov dx, snake[bx]
	mov bl, 0001010b
	call put_char_at_coord
	
	mov bx, [tail]
	shl bx, 1
	mov dx, snake[bx]
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
	pop bx
	ret
endp get_snake_length

swap proc
	mov ax, [tail]
	mov bx, [prev_head]
	;mov cx, [head]
	mov [prev_head], ax
	mov [tail], bx
	test [flags], 1
	jnz @@head_was_decrementing

	;;head was incrementing
	or [flags], 1
	cmp [prev_head], 1
	jae @@simple_swap
		mov [head], MAX_SNAKE_LEN-1
	jmp @@exit
	
	@@simple_swap:
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
	mov al, ' '
	mov bl, 0
	call put_char_at_coord ;todo в режиме самоперечения не стирать!
	call change_tail_pos
	pop dx bx ax
	ret
endp remove_tail

get_prev_head proc
	push bx
	mov si, [prev_head]
	shl si, 1
	mov dx, snake[si]
	pop bx
	ret
endp get_prev_head


move_head proc
;DX = next coords	
	cmp dl, 18h
	jne @@cont
	nop
@@cont:
	mov si, [head]
	shl si, 1
	mov snake[si], dx
	mov al, '*';178
	mov bl, 0001010b
	call put_char_at_coord

	call get_prev_head
	mov bl, 010b
	call put_char_at_coord
	
	call change_head_pos
	ret
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