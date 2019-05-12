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
	
	SWAP_WALL = 1Dh
	DEATH_WALL = 9Dh
	TELEPORT_WALL = 11h
	SNAKE_CHAR = '*'
	
	;MAX_SNAKE_LEN = (FIELD_WIDTH - 15)*(FIELD_HEIGHT - 10)
	MAX_SNAKE_LEN = (FIELD_WIDTH - 2)*(FIELD_HEIGHT - 2)
	;MAX_SNAKE_LEN = 128
	
	mode_num		db 0
	page_num		db 0
	
	snake dw MAX_SNAKE_LEN dup(0) ; координаты?
	snake_init_length db 18
	
	
	prev_head dw 0
	head dw 0
	tail dw 0
	
	flags db 0 ; X|X|X|X|X|PAUSE|DEAD|DEC\INC tail
	self_cross_modes db 1 ;0 = можно самопересекаться 1=можно, но откусится хвост 2=нельзя
	
	output db 4 dup(0), 20h, '$'

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
	
	xor ax, ax
	mov al, [snake_init_length]
	mov [head], ax
	dec al
	mov [prev_head], ax
	
	mov ah, 00h
	mov al, 2
	int 10h
	
	mov ah, 05h
	mov al, 0
	int 10h
	
	call init_pause
	call init_game_over
	mov bh, 0
	call init_snake
	call draw_full_snake
	mov bl, 101b
	call draw_swap_wall
	call draw_death_wall
	call draw_teleport_wall
	
@@loop:
	mov al, [flags]
	and al, 10b
	jnz @@exit ;DEAD

	call wait_for_key_press
	cmp ah, 01
	je @@exit
	
	cmp ah, 39h
	je @@space_handler
	
	test [flags], 100b
	jnz @@loop ;PAUSE
	
	
	@@try_move:
	cmp ah, RIGHT_ARROW
	je @@move_right
	
	cmp ah, LEFT_ARROW
	je @@move_left
	
	cmp ah, UP_ARROW
	je @@move_up
	
	cmp ah, DOWN_ARROW
	je @@move_down

	jmp @@loop
	
@@move_right:
	call get_prev_head
	inc dl
	call move_snake
	jmp @@loop
	
@@move_left:
	call get_prev_head
	dec dl
	call move_snake
	jmp @@loop
	
@@move_up:
	call get_prev_head
	dec dh
	call move_snake
	jmp @@loop
	
@@move_down:
	call get_prev_head
	inc dh
	call move_snake
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


@@exit:
	mov ah, 05h
	mov al, 02h
	int 10h
	call wait_for_key_press
	call_restore_screen_state
	call_exit

	
init_snake proc
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
end start