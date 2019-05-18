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
	ESC_KEY = 01h
	R_KEY = 13h
	SPACE_KEY = 39h
	
	SWAP_WALL = 1Dh
	DEATH_WALL = 9Dh
	TELEPORT_WALL = 11h
	SNAKE_CHAR = '*'
	
	FOOD_GOOD = 02
	FOOD_COLOR_GOOD = 1100b
	FOOD_DEATH = 145
	FOOD_COLOR_DEATH = 100b
	FOOD_STRANGE = 127
	FOOD_COLOR_STRANGE = 1101b
	FOOD_SUPER = 15h
	FOOD_COLOR_SUPER = 10100100b

	MAX_SNAKE_LEN = (FIELD_WIDTH - 2)*(FIELD_HEIGHT - 2)
	
	MAX_FOOD_COUNT = 30
	
	mode_num		db 0
	page_num		db 0
	
	snake dw MAX_SNAKE_LEN dup(0) ; координаты?
	snake_init_length db 15
	snake_length_record dw 0
	
	food_init_count db 3
	
	prev_head dw 0
	head dw 0
	tail dw 0
	
	flags db 0 ; X|X|X|X|X|X|DEAD|DEC\INC tail
	self_cross_modes db 0 ;0 = можно самопересекаться 1=можно, но откусится хвост 2=нельзя
	upper_wall_type db 1; 
	direction db 0; 0 = стоим, остальное - сканкоды стрелок
	speed dw 5
	death_mode db 0
	hard_mode db 0
	
	output db 4 dup(0), 20h, '$'
	output_len = $ - output
	
	stat_snake_length				db '             Snake length:           '
	stat_snake_length_len	= $ - stat_snake_length
	stat_max_snake_length			db '                   Record:           '
	stat_max_snake_length_len = $ - stat_max_snake_length
	stat_food_eaten					db '      Good food (',FOOD_GOOD,') eaten:           '
	stat_food_eaten_len		= $ - stat_food_eaten
	stat_strange_food_eaten			db '   Strange food (',FOOD_STRANGE,') eaten:           '
	stat_strange_food_eaten_len		= $ - stat_strange_food_eaten
	stat_super_food_eaten			db '     Super food (',FOOD_SUPER,') eaten:           '
	stat_super_food_eaten_len		= $ - stat_super_food_eaten
	
	stat_hint db '    Press R to restart and ESC to exit!!!'
	stat_hint_len = $ - stat_hint
	
	good_food_eaten dw 0
	strange_food_eaten dw 0
	super_food_eaten dw 0
	
	super_food_cooldown db 0
	SUPER_FOOD_COOLDOWN_TIME = 5
	
	CR = 0Dh
	LF = 0Ah
	
	help_msg db "Controls:", CR, LF, "    ",18h,19h,1Ah,1Bh,"   - movement.", CR, LF, "    -/+    - decrease/increase snake's speed.", CR, LF, "    SPACE  - pause. Press SPACE again to continue.", CR, LF,"    F1     - this help. Press F1 again to continue.", CR, LF, "    ESC    - stop game. Press R to restart or ESC again to exit.", CR, LF, CR, LF, "Walls:", CR, LF, "    ", DEATH_WALL,"  -  go in and die", CR, LF, "    ", SWAP_WALL,"  -  go in and swap head and tail", CR, LF, "    ",TELEPORT_WALL,"  -  go in and teleport to the other side", CR, LF, CR, LF, "Foods:", CR, LF, "    ",FOOD_DEATH,"  -  eat it and die", CR, LF, "    ",FOOD_GOOD,"  -  eat it and grow", CR, LF, "    ",FOOD_STRANGE,"  -  eat it and see what happens"
	help_msg_len = $ - help_msg
	
	

	

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	include moves.asm
	include paint.asm
	include sound.asm
	include init.asm

main:
	include argpars.asm
@@prog:
	call_save_screen_state

@@new_game:
	call setup
	
@@loop:	
	call print_quick_stat
	call try_add_deadly_food
	call try_add_strange_food
	call delay

	mov al, [flags]
	and al, 10b
	jnz @@exit ;DEAD

	call check_for_key_press
	mov ah, [direction]
	jz @@try_move

	call wait_for_key_press
	cmp ah, ESC_KEY
	je @@exit
	
	cmp ah, SPACE_KEY
	je @@space_handler
	
	cmp ah, F1
	je @@help_handler
	
	cmp ah, MINUS
	je @@decrease_speed

	cmp ah, PLUS
	je @@increase_speed

	@@try_move:
		call arrow_handler

	jmp @@loop
	
@@exit:
	call determine_final_song
	call print_stat
	mov ah, 05h
	mov al, 02h
	int 10h
	call play_song
	@@exit_loop:
		call wait_for_key_press
		cmp ah, R_KEY ;Restart
		je @@new_game
		cmp ah, ESC_KEY
		jne @@exit_loop

	call_restore_screen_state
@@just_exit:
	call_exit
	
@@help_handler:
	call help_handler
	jmp @@loop

@@space_handler:
	call space_handler
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
	
space_handler:
	mov ah, 05h
	mov al, 01h
	int 10h
	@@loop:
		call wait_for_key_press
		cmp ah, SPACE_KEY
		jne @@loop
	mov ah, 05h
	mov al, 00h
	int 10h
	ret
	
determine_final_song proc
	call get_snake_length
	cmp [snake_length_record], 0
	je @@first_turn

	cmp ax, [snake_length_record]
	jbe @@fail
		mov [snake_length_record], ax

@@father:
	mov si, offset FATHER
	ret
	
@@first_turn:
	mov [snake_length_record], ax

@@fail:
	mov si, offset FAIL
	ret
endp determine_final_song

quick_stat_length db 'Length: '
quick_stat_length_len = $ - quick_stat_length

print_quick_stat proc
	mov dh, FIELD_HEIGHT - 1
	mov dl, 0
	mov bh, 0
	mov si, offset quick_stat_length
	mov cx, offset quick_stat_length_len
	mov bl, 010b
	call put_str
	
	call get_snake_length
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	mov bl, 111b
	call put_str

	mov al, FOOD_GOOD
	mov bl, FOOD_COLOR_GOOD
	call put_char
	mov bl, 111b
	inc dl
	call move_cursor
	mov al, ':'
	call put_char
	add dl, 2
	call move_cursor
	
	mov ax, [good_food_eaten]
	call put_reg
	
	
	mov al, FOOD_STRANGE
	mov bl, FOOD_COLOR_STRANGE
	call put_char
	mov bl, 111b
	inc dl
	call move_cursor
	mov al, ':'
	call put_char
	add dl, 2
	call move_cursor
	
	mov ax, [strange_food_eaten]
	call put_reg
	
	mov al, FOOD_SUPER
	mov bl, FOOD_COLOR_SUPER
	and bl, 01111111b
	call put_char
	mov bl, 111b
	inc dl
	call move_cursor
	mov al, ':'
	call put_char
	add dl, 2
	call move_cursor
	mov ax, [super_food_eaten]
	call put_reg
	
	call hide_cursor
	ret
endp print_quick_stat

put_reg proc
;AX - value
;BH - page_num
;BL = attribute
;DX = coords
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str
	ret
endp put_reg

print_stat proc
	push si
	mov si, offset stat_snake_length
	mov cx, offset stat_snake_length_len
	mov bh, 2
	mov bl, 010b
	mov dh, 10
	mov dl, 15
	call put_str
	
	call get_snake_length
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
	
	mov ax, [good_food_eaten]
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str
	
	inc dh
	mov dl, 15
	mov si, offset stat_strange_food_eaten
	mov cx, offset stat_strange_food_eaten_len
	call put_str
	
	mov ax, [strange_food_eaten]
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str
	
	inc dh
	mov dl, 15
	mov si, offset stat_super_food_eaten
	mov cx, offset stat_super_food_eaten_len
	call put_str
	
	mov ax, [super_food_eaten]
	call num_to_str
	mov si, offset output
	mov cx, output_len - 1
	call put_str

	add dh, 3
	mov dl, 15
	mov si, offset stat_hint
	mov cx, offset stat_hint_len
	or bl, 10000000b
	call put_str
	
	call hide_cursor
	
	pop si
	ret
endp print_stat

try_add_deadly_food proc
	cmp [death_mode], 0
	je @@check_hard
	
@@check_hard:
	cmp [hard_mode], 0
	je @@exit
	
	mov di, 77
	call get_chance
	jnz @@exit
	
	call add_death_food
@@exit:
	ret
endp try_add_deadly_food

try_add_strange_food proc
	cmp [hard_mode], 0
	je @@exit
	
	mov di, 70
	call get_chance
	jnz @@exit
	
	call add_strange_food
@@exit:
	ret
endp try_add_strange_food

get_chance:
;DI = upper edge
;ZF = 1 iff got chance
	mov si, 0
	call random
	xor ax, 3
	ret
	
add_death_food:
	mov al, FOOD_DEATH
	mov bl, FOOD_COLOR_DEATH
	mov cx, 1
	call init_food_item
	ret
	
add_strange_food:
	mov al, FOOD_STRANGE
	mov bl, FOOD_COLOR_STRANGE
	mov cx, 1
	call init_food_item
	ret

end start