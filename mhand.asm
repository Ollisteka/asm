jmp main

mouse_handler proc
;АХ = условие вызова
;ВХ = состояние кнопок
;СХ, DX — X- и Y-координаты курсора
;SI, DI — счетчики последнего перемещения по горизонтали и вертикали (единицы измерения для этих счетчиков — мики, 1/200 дюйма)
;DS — сегмент данных драйвера мыши
	push ds cs
	pop ds
	
	test ax, 1
	jnz movement_handler
	
	test ax, 8
	jnz pkm_handler
	
	jmp @@exit

pkm_handler:
	push cx dx
	call check_circle_intersect
	pop dx cx
	test ax, ax
	jnz @@exit
	call check_rectangle_intersect
	jmp @@exit
	
	
;;;;;
drag_handler:
	call try_move_construction
	pop ds
	retf
	
@@exit:
	pop ds
	retf


;;;;;
movement_handler:
	test bx, 1 ; нажата ЛКМ
	jnz drag_handler

	call try_move_circle
	pop ds
	retf
	
endp mouse_handler

try_move_construction proc
	push cx dx
	call is_coord_on_rectangle
	pop dx cx
	jnz @@try_move
	push cx dx
	call is_coord_in_circle
	pop dx cx
	jz @@exit
	
@@try_move:
	call hide_cursor
	
	push cx dx
	call erase_rectangle_and_circle
	pop dx cx
	
	
	mov ax, [prev_x]
	mov bx, [prev_y]
	
	mov [prev_x], cx
	mov [prev_y], dx
	
	sub cx, ax ;X_offset, can be negative
	sub dx, bx
	
	add [upper_left_x], cx
	js @@make_x_zero
	mov ax, [upper_left_x]
	add ax, FIELD_WIDTH + LINE_WIDTH
	cmp ax, MAX_WIDTH
	jae @@make_x_max

	jmp @@shift_y
	
@@make_x_zero:
	mov [upper_left_x], 0
	jmp @@shift_y
	
@@make_x_max:
	mov [upper_left_x], MAX_WIDTH - FIELD_WIDTH - LINE_WIDTH
	jmp @@shift_y
	

@@shift_y:
	add [upper_left_y], dx
	js  @@make_y_zero
	mov ax, [upper_left_y]
	add ax, FIELD_HEIGHT + LINE_WIDTH
	cmp ax, MAX_HEIGHT
	jae @@make_y_max
	jmp @@draw
	
@@make_y_zero:
	mov [upper_left_y], 0
	jmp @@draw
	
@@make_y_max:
	mov [upper_left_y], MAX_HEIGHT - FIELD_HEIGHT - LINE_WIDTH
	jmp @@draw
	
@@draw:
	mov al, [field_color]
	call draw_rectangle
	call draw_filled_circle
	jmp @@exit
	
@@exit:
	call show_cursor
	ret

endp try_move_construction


try_move_circle proc
	
	;двигаем шарик
	
	cmp dx, [prev_y]
	ja @@try_move_down
	
	cmp dx, [prev_y]
	jb @@try_move_up
	
	cmp cx, [prev_x]
	ja @@try_move_right
	
	cmp cx, [prev_x]
	jb @@try_move_left
	
	jmp @@exit
	
@@try_move_down:	
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_y]
	inc bx
	call can_move_y_axis
	jz @@exit
	
	@@can_move_down:
		call erase_circle
		inc [center_y]	
		jmp @@repaint_circle
	
@@try_move_up:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_y]
	dec bx
	call can_move_y_axis
	jz @@exit

	@@can_move_up:
		call erase_circle
		dec [center_y]	
		jmp @@repaint_circle
	
@@try_move_right:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	inc bx
	call can_move_x_axis
	jz @@exit
		
	@@can_move_right:
		call erase_circle
		inc [center_x]
		jmp @@repaint_circle
		
@@try_move_left:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	dec bx
    call can_move_x_axis
	jz @@exit
		
	@@can_move_left:
		call erase_circle
		dec [center_x]
		jmp @@repaint_circle
	
@@repaint_circle:
	call draw_filled_circle

@@exit:	
	ret
endp try_move_circle


erase_circle:
	call draw_black_circle
	mov al, [field_color]
	call draw_rectangle
	call show_cursor
	ret
	
erase_rectangle_and_circle:
	call draw_black_circle
	mov al, 0
	call draw_rectangle

	ret

can_move_x_axis proc
;ZF = 0 <=> can
;BX = possible Xcoord
	mov ax, [upper_left_x]
	add ax, LINE_WIDTH/2
	
	mov cx, ax
	add cx, FIELD_WIDTH
	call is_inside
	jz @@false

	mov bx, [center_y]

	mov ax, [upper_left_y]
	mov cx, ax
	add cx, LINE_WIDTH
	call is_inside
	jnz @@true

	mov ax, [upper_left_y]
	add ax, FIELD_HEIGHT
	add cx, FIELD_HEIGHT
	call is_inside
	jnz @@true

	@@false:
		call set_zf	
		ret
	
	@@true:
		call clear_zf	
		ret
endp can_move_x_axis

can_move_y_axis proc
;ZF = 0 <=> can
;BX = possible Ycoord

	mov ax, [upper_left_y]
	add ax, LINE_WIDTH/2
	mov cx, ax
	add cx, FIELD_HEIGHT
	call is_inside
	jz @@false
	
	mov bx, [center_x]
	
	mov ax, [upper_left_x]
	mov cx, ax
	add cx, LINE_WIDTH
	call is_inside
	jnz @@true

	mov ax, [upper_left_x]
	add ax, FIELD_WIDTH
	add cx, FIELD_WIDTH
	call is_inside
	jnz @@true

	@@false:
		call set_zf
		ret
	
	@@true:
		call clear_zf	
		ret
endp can_move_y_axis