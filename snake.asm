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
	
	;MAX_SNAKE_LEN = (FIELD_WIDTH - 15)*(FIELD_HEIGHT - 10)
	MAX_SNAKE_LEN = (FIELD_WIDTH - 2)*(FIELD_HEIGHT - 2)
	;MAX_SNAKE_LEN = 5
	
	mode_num		db 0
	page_num		db 0
	
	snake dw MAX_SNAKE_LEN dup(0) ; координаты?
	snake_init_length db 5
	
	
	prev_head dw 0
	head dw 0
	tail dw 0
	
	output db 4 dup(0), 20h, '$'

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	

main:
	call_save_screen_state
	
	xor ax, ax
	mov [head], 5
	mov [prev_head], 4
	
	mov ah, 00h
	mov al, 2
	int 10h
	
	mov ah, 05h
	mov al, 0
	int 10h
	
	call init_snake
	call draw_full_snake
	
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
	
move_snake proc
	call remove_tail
	call move_head
	ret
endp move_snake

remove_tail proc
	push ax bx dx
	mov si, [tail]
	shl si, 1
	mov dx, snake[si]
	mov al, ' '
	mov bl, 0
	call put_char_at_coord ;todo в режиме самоперечения не стирать!
	call inc_tail
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
	
	call inc_head
	ret
endp move_head

inc_head proc
	push bx
	mov bx, [head]
	print_reg bx
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
		mov al, '*';178
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

endp init_snake
end start