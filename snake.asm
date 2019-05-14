model tiny

.data
	FIELD_WIDTH = 80
	FIELD_HEIGHT = 25
	DISPLAY_MODE = 0449h
	ACTIVE_PAGE = 0462h
	
	UP_ARROW = 48h
	DOWN_ARROW = 50h
	LEFT_ARROW = 4Bh
	RIGHT_ARROW = 4Dh
	
	MINUS = 0Ch
	PLUS = 0Dh
	
	F1 = 3Bh
	
	SWAP_WALL = 1Dh
	DEATH_WALL = 9Dh
	TELEPORT_WALL = 11h
	SNAKE_CHAR = '*'
	
	FOOD_GOOD = 02
	FOOD_COLOR_GOOD = 1100b

	MAX_SNAKE_LEN = (FIELD_WIDTH - 2)*(FIELD_HEIGHT - 2)
	
	MAX_FOOD_COUNT = 30
	
	mode_num		db 0
	page_num		db 0
	
	snake dw MAX_SNAKE_LEN dup(0) ; координаты?
	snake_init_length db 18
	snake_length_record dw 0
	
	
	prev_head dw 0
	head dw 0
	tail dw 0
	
	flags db 0 ; X|X|X|X|X|PAUSE|DEAD|DEC\INC tail
	self_cross_modes db 1 ;0 = можно самопересекаться 1=можно, но откусится хвост 2=нельзя
	upper_wall_type db 1; 
	direction db 0; 0 = стоим, остальное - сканкоды стрелок
	speed dw 5
	
	output db 4 dup(0), 20h, '$'
	output_len = $ - output
	
	stat_snake_length		db 'Snake length:              '
	stat_snake_length_len	= $ - stat_snake_length
	stat_max_snake_length	db '      Record:              '
	stat_max_snake_length_len = $ - stat_max_snake_length
	stat_food_eaten			db '  Food eaten:              '
	stat_food_eaten_len		= $ - stat_food_eaten
	
	CR = 0Dh
	LF = 0Ah
	
	help_msg db "Controls:", CR, LF, "    ",18h,19h,1Ah,1Bh,"   - movement.", CR, LF, "    -/+    - decrease/increase snake's speed.", CR, LF, "    SPACE  - pause. Press SPACE again to continue.", CR, LF,"    F1     - this help. Press F1 again to continue.", CR, LF, "    ESC    - stop game. Then press R to restart or any other key to exit.", CR, LF, CR, LF, "Walls:", CR, LF, "    ", DEATH_WALL,"  -  go in and die", CR, LF, "    ", SWAP_WALL,"  -  go in and swap head and tail", CR, LF, "    ",TELEPORT_WALL,"  -  go in and teleport to the other side", CR, LF, CR, LF, "Foods:", CR, LF, "    A  -  eat it and die", CR, LF, "    B  -  eat it and grow", CR, LF, "    C  -  eat it and see what happens"
	help_msg_len = $ - help_msg

	

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	include moves.asm
	include paint.asm

main:
	call_save_screen_state

@@new_game:
	mov [direction], 0
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
	
	call init_pause
	call init_game_over
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
	
@@loop:	
	call delay
	;push ax
	;call clear_byte_buff
	;call get_snake_length
	;call num_to_str
	;call_print output
	;pop ax
	mov al, [flags]
	and al, 10b
	jnz @@exit ;DEAD

	call check_for_key_press
	mov ah, [direction]
	jz @@try_move

	call wait_for_key_press
	cmp ah, 01
	je @@exit
	
	cmp ah, 39h
	je @@space_handler
	
	cmp ah, F1
	je @@help_handler
	
	cmp ah, MINUS
	je @@decrease_speed

	cmp ah, PLUS
	je @@increase_speed
	
	test [flags], 100b
	jnz @@loop ;PAUSE	
	
	@@try_move:
		call arrow_handler

	jmp @@loop
	
@@exit:
	call print_length
	mov ah, 05h
	mov al, 02h
	int 10h
	call wait_for_key_press
	cmp ah, 13h ;Restart
	jne @@cont_ex
	jmp @@new_game
@@cont_ex:
	call_restore_screen_state
	call_exit
	
@@help_handler:
	call help_handler
	jmp @@loop

@@space_handler:
	test [flags], 100b
	jz @@set_pause
	@@unset_pause:
		and [flags], 11111011b
		mov ah, 05h
		mov al, 00h
		int 10h
		jmp @@try_move
	
	@@set_pause:
		or [flags], 100b
		mov ah, 05h
		mov al, 01h
		int 10h
		jmp @@loop	

	
@@increase_speed:
	mov ah, [direction]
	cmp [speed], 2
	je @@try_move
	dec [speed]
	jmp @@try_move


@@decrease_speed:
	mov ah, [direction]
	cmp [speed], 15
	je @@try_move
	inc [speed]
	jmp @@try_move
	
help_handler:
	mov ah, 05h
	mov al, 03h
	int 10h
	@@loop:
		call wait_for_key_press
		cmp ah, F1
		jne @@loop
	mov ah, 05h
	mov al, 00h
	int 10h
	ret
	
init_help proc
	call draw_help
	mov bp, offset help_msg
	mov cx, offset help_msg_len
	mov bh, 3
	mov bl, 1001b
	mov dh, 7
	mov dl, 0
	mov al, 1
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

init_food proc
	call get_random_pos
	call is_intersected
	jz init_food
	mov al, FOOD_GOOD
	mov bl, FOOD_COLOR_GOOD
	mov bh, 0
	call put_char_at_coord
	ret
endp init_food

print_length proc
	mov si, offset stat_snake_length
	mov cx, offset stat_snake_length_len
	mov bh, 2
	mov bl, 010b
	mov dh, 10
	mov dl, 15
	call put_str
	
	call get_snake_length
	cmp ax, [snake_length_record]
	jbe @@not_new_record
		mov [snake_length_record], ax
@@not_new_record:
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str
	
	inc dh
	mov dl, 15
	mov si, offset stat_max_snake_length
	mov cx, offset stat_max_snake_length_len
	call put_str
	
	mov ax, [snake_length_record]
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str
	
	inc dh
	mov dl, 15
	mov si, offset stat_food_eaten
	mov cx, offset stat_food_eaten_len
	call put_str
	ret
endp print_length

end start