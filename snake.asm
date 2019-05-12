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
	TELEPORT_WALL = 11h
	SNAKE_CHAR = '*'
	
	;MAX_SNAKE_LEN = (FIELD_WIDTH - 15)*(FIELD_HEIGHT - 10)
	MAX_SNAKE_LEN = (FIELD_WIDTH - 2)*(FIELD_HEIGHT - 2)
	;MAX_SNAKE_LEN = 128
	
	mode_num		db 0
	page_num		db 0
	
	snake dw MAX_SNAKE_LEN dup(0) ; координаты?
	snake_init_length db 20
	
	
	prev_head dw 0
	head dw 0
	tail dw 0
	
	flags db 0 ; X|X|X|X|X|X|X|DEC\INC tail
	
	output db 4 dup(0), 20h, '$'

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	include moves.asm
	

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
	
	call init_snake
	call draw_full_snake
	mov bl, 101b
	call draw_swap_wall
	call draw_teleport_wall
	
@@loop:
	call wait_for_key_press
	cmp ah, 01
	je @@exit
	
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


@@exit:
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
	
draw_full_snake proc
	mov si, offset snake
	xor cx, cx
	mov cl, [snake_init_length]
	mov bl, 010b
	@@loop:
		lodsw
		mov dx, ax
		mov al, SNAKE_CHAR
		cmp cl, 1
		ja @@not_head
			mov bl, 0001010b
	@@not_head:
		push cx
		call put_char_at_coord
		pop cx
		loop @@loop
	ret
endp draw_full_snake

draw_swap_wall proc
	mov al, SWAP_WALL
	mov cx, FIELD_HEIGHT
	mov dl, FIELD_WIDTH-1
	call draw_vert_wall
	ret
endp draw_swap_wall

draw_teleport_wall proc
	mov al, TELEPORT_WALL
	mov cx, FIELD_HEIGHT
	mov dl, 0
	call draw_vert_wall
	ret
endp draw_teleport_wall

draw_vert_wall proc
;AL = char
;CX = length
;DL = column
	mov dh, 0 ;row
	@@loop:
		push cx
		call put_char_at_coord
		pop cx
		inc dh
		loop @@loop
	ret
endp draw_vert_wall

endp init_snake
end start