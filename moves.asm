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
	call get_char_at_coord
	cmp al, FOOD_GOOD
	je @@grow
	
	cmp al, FOOD_DEATH
	je @@death_wall
	
	cmp al, FOOD_STRANGE
	je @@strange_food
	
	cmp al, FOOD_SUPER
	je @@super_food
	
	cmp dl, FIELD_WIDTH-1
	je @@swap_wall
	
	cmp dl, 0
	je @@teleport_wall
	
	cmp dh, FIELD_HEIGHT-1
	je @@death_wall
	
	cmp dh, 0
	je @@upper_wall

@@simple:
	cmp [super_food_cooldown], 0
	je @@1
		dec [super_food_cooldown]
		jmp @@move_head
	@@1:
	mov cx, 1
	call remove_tail
	jmp @@move_head
@@grow:
	push dx
	call create_good_food
	inc [good_food_eaten]
	call try_create_super_food
	pop dx
@@move_head:
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
	
@@upper_wall:
	cmp [upper_wall_type], 0
	je @@death_wall
	cmp [upper_wall_type], 1
	je @@swap_wall
	cmp [upper_wall_type], 2
	jne @@death_wall
		;teleport_wall
		mov dh, FIELD_HEIGHT-2
		jmp @@simple
		
@@super_food:
	mov [super_food_cooldown], SUPER_FOOD_COOLDOWN_TIME
	inc [super_food_eaten]
	call play_super_food_sound
	jmp @@move_head

@@strange_food:
	mov si, 1
	call get_snake_length
	sub ax, 2
	mov di, ax
	call random
	mov cx, ax
	inc cx
	@@dec_tail:
		call remove_tail
		loop @@dec_tail


	mov al, FOOD_STRANGE
	mov bl, FOOD_COLOR_STRANGE
	mov cx, 1
	call init_food_item
	inc [strange_food_eaten]
	call play_strange_food_sound
	
	jmp @@move_head

@@exit:
	ret
endp move_snake

try_create_super_food proc
	mov dx, [good_food_eaten]
	xor dh, dh
	and dl, 111b
	cmp dl, SUPER_FOOD_COOLDOWN_TIME
	jne @@exit
		mov al, FOOD_SUPER
		mov bl, FOOD_COLOR_SUPER
		mov cx, 1
		call init_food_item
		call play_super_food_creation_sound
@@exit:
	ret
endp try_create_super_food

create_good_food:
	mov al, FOOD_GOOD
	mov bl, FOOD_COLOR_GOOD
	mov cx, 1
	call init_food_item
	call play_good_food_sound
	ret


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
	push ax bx cx dx
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
	pop dx cx bx ax
	ret
endp remove_tail

is_intersected proc
;RETURNS
;Z=1 iff intersection

;INPUT:
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

get_prev_head proc
	get_snake_coord prev_head
	ret
endp get_prev_head

get_tail proc
	get_snake_coord tail
	ret
endp get_tail

delay proc
	mov cx, [speed]
	@@outer_loop:
		push cx
		mov cx, 0ffffh
		@@loop: loop $
		pop cx
		loop @@outer_loop
	ret
endp delay


get_random_pos proc
;DX = pos
	mov si, 1
	mov di, FIELD_HEIGHT-2
	call random
	push ax
	mov di, FIELD_WIDTH-2
	call random
	mov bx, ax
	pop ax
	mov ah, al
	mov al, bl
	mov dx, ax
	ret
endp get_random_pos

get_free_random_pos proc
	push ax bx cx
	@@regenerate:
		call get_random_pos
		call get_char_at_coord
		cmp al, 20h
		jne @@regenerate
	pop cx bx ax
	ret
endp get_free_random_pos