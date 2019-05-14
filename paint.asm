jmp main


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

draw_upper_wall proc
	cmp [upper_wall_type], 0
	je @@death_wall
	cmp [upper_wall_type], 1
	je @@swap_wall
	cmp [upper_wall_type], 2
	je @@teleport_wall
	jmp @@death_wall
	
@@death_wall:	
	mov al, DEATH_WALL
	jmp @@draw
@@swap_wall:	
	mov al, SWAP_WALL
	jmp @@draw
@@teleport_wall:	
	mov al, TELEPORT_WALL
	jmp @@draw
@@draw:
	mov cx, FIELD_WIDTH-2
	mov dh, 0
	mov dl, 1 ;column
	call draw_hor_wall
	ret
endp draw_upper_wall

draw_swap_wall proc
	mov al, SWAP_WALL
	mov cx, FIELD_HEIGHT
	mov dl, FIELD_WIDTH-1
	mov dh, 0 ;row
	call draw_vert_wall
	ret
endp draw_swap_wall


draw_teleport_wall proc
	mov al, TELEPORT_WALL
	mov cx, FIELD_HEIGHT
	mov dl, 0
	mov dh, 0 ;row
	call draw_vert_wall
	ret
endp draw_teleport_wall


draw_death_wall proc
	mov al, DEATH_WALL
	mov cx, FIELD_WIDTH-1
	mov dh, FIELD_HEIGHT-1
	mov dl, 0 ;column
	call draw_hor_wall
	ret
endp draw_death_wall


init_game_over proc
	mov al, 0B2h
	mov bl, 1100b
	mov bh, 2

; -- G	
	mov dh, 3
	mov dl, 5 ;column
	call draw_EG_common
	
	add dh, 3
	add dl, 5 ;column
	mov cx, 2
	call draw_hor_wall

;--G

;A
	mov dh, 3
	mov dl, 13 ;column
	call draw_EG_common
	
	mov bl, 0
	
	mov dh, 3+4
	mov dl, 13+2 ;column
	mov cx, 3
	call draw_hor_wall
	
	mov bl, 1100b
	
	mov dh, 3+2
	mov dl, 13+2 ;column
	mov cx, 3
	call draw_hor_wall
	
	mov dh, 3
	mov dl, 13+5 ;column
	mov cx, 2
	@@1:
		push cx
		mov cx, 5
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@1
	
;A

;M
	mov dh, 3
	mov dl, 21 ;column
	mov cx, 2
	@@M1:
		push cx
		mov cx, 5
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@M1

	inc dh
	mov cx, 1
	@@M2:
		push cx
		mov cx, 2
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@M2
		
	inc dh
	mov cx, 2
	@@M3:
		push cx
		mov cx, 2
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@M3
		
	dec dh
	mov cx, 2
	push dx
	call draw_vert_wall
	pop dx
	inc dl
	
	dec dh
	mov cx, 2
	@@M4:
		push cx
		mov cx, 5
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@M4		
;M
;E
	add dl, 1 ;column
	call draw_EG_common
	
	mov dh, 3+2
	mov dl, 29+2 ;column
	mov cx, 3
	call draw_hor_wall
;E

;O
	mov dh, 3
	mov dl, 43
	call draw_EG_common
	
	mov dl, 43+5 ;column
	mov cx, 2
	@@O1:
		push cx
		mov cx, 5
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@O1
		
	mov bl, 0
	
	mov dh, 3+2
	mov dl, 43+2 ;column
	mov cx, 3
	call draw_hor_wall
	
	mov bl, 1100b
;O
;V
	mov dh, 3
	mov dl, 51
	mov cx, 2
	@@V1:
		push cx
		mov cx, 4
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@V1
	
	add dh, 3
	mov cx, 2
	@@V2:
		push cx
		mov cx, 2
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@V2
	
	sub dh, 3
	mov cx, 2
	@@V3:
		push cx
		mov cx, 4
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@V3
;V
;E
	add dl, 1 ;column
	call draw_EG_common
	
	mov dh, 3+2
	mov dl, 57+2 ;column
	mov cx, 3
	call draw_hor_wall
;E
;R
	mov dh, 3
	mov dl, 66
	call draw_EG_common
	
	mov bl, 0
	mov dh, 3+4
	mov dl, 66+2
	mov cx, 5
	call draw_hor_wall
	
	mov dh, 3+2
	mov dl, 66+2
	mov cx, 5
	call draw_hor_wall
	
	mov bl, 1100b
	
	mov dh, 3+2
	mov dl, 66+2 ;column
	mov cx, 3
	call draw_hor_wall
	
	mov dh, 3
	mov dl, 66+5	
	mov cx, 2
	@@R1:
		push cx
		mov cx, 4
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@R1
		
	add dh, 3
	mov cx, 2
	@@R2:
		push cx
		mov cx, 2
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@R2

	
;R
	ret
endp init_game_over

draw_EG_common proc
;dh, dl = base
	push dx
	mov cx, 2
	@@1:
		push cx
		mov cx, 5
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@1
	pop dx
	push dx
	;mov dh, 3
	add dl, 2 ;column
	mov cx, 5
	call draw_hor_wall
	
	pop dx
	push dx

	add dh, 4
	add dl, 2 ;column
	mov cx, 5
	call draw_hor_wall
	
	pop dx
	push dx
	
	add dh, 2
	add dl, 4 ;column
	mov cx, 3
	call draw_hor_wall
	
	pop dx
	ret
endp draw_EG_common

init_pause proc
	mov al, 0B1h
	mov bl, 1100b
	mov bh, 1
	mov cx, 5

	mov dl, (FIELD_WIDTH-1)/2 - 6
	mov dh, 5
	@@left:
		push cx
		mov cx, 15
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@left
		
	mov cx, 5
	mov dl, (FIELD_WIDTH-1)/2 + 6
	@@right:
		push cx
		mov cx, 15
		push dx
		call draw_vert_wall
		pop dx
		inc dl
		pop cx
		loop @@right
		
	mov dh, 51
	call move_cursor
	ret
endp init_pause


draw_vert_wall proc
;AL = char
;CX = length
;DL = column	
;DH = row
	@@loop:
		push cx
		call put_char_at_coord
		pop cx
		inc dh
		loop @@loop
	ret
endp draw_vert_wall


draw_hor_wall proc
;AL = char
;CX = length
;DH = row
	@@loop:
		push cx
		call put_char_at_coord
		pop cx
		inc dl
		loop @@loop
	ret
endp draw_hor_wall