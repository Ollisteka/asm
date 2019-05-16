setup proc
	mov [direction], 0
	mov [good_food_eaten], 0
	mov [flags], 0
	xor ax, ax
	mov al, [snake_init_length]
	mov [head], ax
	dec al
	mov [prev_head], ax
	mov [tail], 0

	mov ah, 00h
	mov al, 2
	int 10h
	
	mov ah, 05h
	mov al, 0
	int 10h
	
	call draw_pause
	call draw_game_over
	call init_help
	mov bh, 0
	call init_snake
	call init_food
	call draw_full_snake
	mov bl, 101b
	call draw_swap_wall
	call draw_death_wall
	call draw_teleport_wall
	call draw_upper_wall
endp setup

init_help proc
	call draw_help
	mov bp, offset help_msg
	mov cx, help_msg_len
	mov bh, 3
	mov bl, 1001b
	mov dh, 7
	mov dl, 0
	mov al, 0
	mov ah, 13h
	int 10h
	ret
endp init_help
	
	
init_snake proc
	mov di, offset snake
	mov ax, 0
	mov cx, MAX_SNAKE_LEN
	rep stosw

	mov di, offset snake
	xor cx, cx
	mov cl, [snake_init_length]
	mov ah, FIELD_HEIGHT / 2 ;row
	mov al, 5 ;column
	@@loop:
		stosw
		inc al
		loop @@loop
	ret
endp init_snake

init_food proc
	mov al, FOOD_GOOD
	mov bl, FOOD_COLOR_GOOD
	xor cx, cx
	mov cl, [food_init_count]
	call init_food_item
	
	mov al, FOOD_DEATH
	mov bl, FOOD_COLOR_DEATH
	mov cx, 1
	call init_food_item
	
	mov al, FOOD_STRANGE
	mov bl, FOOD_COLOR_STRANGE
	mov cx, 1
	call init_food_item
	
	ret
endp init_food

init_food_item proc
;AL=FOOD ICON
;BL=FOOD COLOR
;CX=count
	push dx
@@regenerate:
	call get_free_random_pos
	mov bh, 0
	call put_char_at_coord
	loop @@regenerate
	pop dx
	ret
endp init_food_item
