jmp main

CIRCLE_OFFSET = 3

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
movement_handler:
	test bx, 1 ; нажата ЛКМ
	jnz drag_handler

	call try_move_circle
	jmp @@exit
	
;;;;;
drag_handler:
	call try_move_construction
	jmp @@exit
	
@@exit:
	pop ds
	retf
	
endp mouse_handler

try_move_construction proc
	push cx dx
	mov cx, [prev_x]
	mov dx, [prev_y]
	call is_coord_on_rectangle
	pop dx cx
	jnz @@try_move
	push cx dx
	mov cx, [prev_x]
	mov dx, [prev_y]
	call is_coord_in_circle
	pop dx cx
	jnz @@try_move
	jmp @@exit
	
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
	
	add [center_x], cx
	add [upper_left_x], cx
	js @@make_x_zero
	mov ax, [upper_left_x]
	add ax, FIELD_WIDTH + LINE_WIDTH
	cmp ax, MAX_WIDTH
	jae @@make_x_max

	jmp @@shift_y
	
@@make_x_zero:
	mov bx, [upper_left_x]
	sub [center_x], bx
	mov [upper_left_x], 0
	jmp @@shift_y
	
@@make_x_max:
	mov bx, [upper_left_x]
	sub bx, MAX_WIDTH
	add bx, FIELD_WIDTH
	add bx, LINE_WIDTH
	sub [center_x], bx
	mov [upper_left_x], MAX_WIDTH - FIELD_WIDTH - LINE_WIDTH
	jmp @@shift_y
	

@@shift_y:
	add [center_y], dx
	add [upper_left_y], dx
	js  @@make_y_zero
	mov ax, [upper_left_y]
	add ax, FIELD_HEIGHT + LINE_WIDTH
	cmp ax, MAX_HEIGHT
	jae @@make_y_max
	jmp @@fix_circle
	
@@make_y_zero:
	mov bx, [upper_left_y]
	sub [center_y], bx
	mov [upper_left_y], 0
	jmp @@fix_circle
	
@@make_y_max:
	mov bx, [upper_left_y]
	sub bx, MAX_HEIGHT
	add bx, FIELD_HEIGHT
	add bx, LINE_WIDTH
	sub [center_y], bx
	mov [upper_left_y], MAX_HEIGHT - FIELD_HEIGHT - LINE_WIDTH
	jmp @@fix_circle
	
@@fix_circle:
	mov ax, [center_x]
	sub ax, CIRCLE_RADIUS
	js @@make_c_x_zero
	
	add ax, CIRCLE_RADIUS
	add ax, CIRCLE_RADIUS
	cmp ax, MAX_WIDTH
	jae @@make_c_x_max
	
	mov ax, [center_y]
	sub ax, CIRCLE_RADIUS
	js @@make_c_y_zero
	
	add ax, CIRCLE_RADIUS
	add ax, CIRCLE_RADIUS
	cmp ax, MAX_HEIGHT
	jae @@make_c_y_max
	
	jmp @@draw
	
@@make_c_x_zero:
	sub [center_x], ax
	sub [upper_left_x], ax
	jmp @@draw
	
@@make_c_y_zero:
	sub [center_y], ax
	sub [upper_left_y], ax
	jmp @@draw
	
@@make_c_x_max:
	sub ax, MAX_WIDTH
	sub [center_x], ax
	sub [upper_left_x], ax
	jmp @@draw
	
@@make_c_y_max:
	sub ax, MAX_HEIGHT
	sub [center_y], ax
	sub [upper_left_y], ax
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
	add bx, CIRCLE_OFFSET
	call can_move_y_axis
	jz @@exit
	
	@@can_move_down:
		call erase_circle
		add [center_y], CIRCLE_OFFSET	
		jmp @@repaint_circle
	
@@try_move_up:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_y]
	sub bx, CIRCLE_OFFSET
	call can_move_y_axis
	jz @@exit

	@@can_move_up:
		call erase_circle
		sub [center_y], CIRCLE_OFFSET
		jmp @@repaint_circle
	
@@try_move_right:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	add bx, CIRCLE_OFFSET
	call can_move_x_axis
	jz @@exit
		
	@@can_move_right:
		call erase_circle
		add [center_x], CIRCLE_OFFSET
		jmp @@repaint_circle
		
@@try_move_left:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	sub bx, CIRCLE_OFFSET
    call can_move_x_axis
	jz @@exit
		
	@@can_move_left:
		call erase_circle
		sub [center_x], CIRCLE_OFFSET
		jmp @@repaint_circle
	
@@repaint_circle:
	call hide_cursor
	call draw_filled_circle
	call show_cursor

@@exit:	
	ret
endp try_move_circle


erase_circle:
	call hide_cursor
	call draw_black_circle
	mov al, [field_color]
	call draw_rectangle
	call show_cursor
	ret
	
erase_rectangle_and_circle:
	call hide_cursor
	call draw_black_circle
	mov al, 0
	call draw_rectangle
	call show_cursor
	ret

can_move_x_axis proc
;ZF = 0 <=> can
;BX = possible Xcoord
	push bx
	sub bx, CIRCLE_RADIUS
	cmp bx, 0
	pop bx
	jl @@false
	
	push bx
	add bx, CIRCLE_RADIUS
	cmp bx, MAX_WIDTH
	pop bx
	jg @@false


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

	push bx
	sub bx, CIRCLE_RADIUS
	cmp bx, 0
	pop bx
	jl @@false
	
	push bx
	add bx, CIRCLE_RADIUS
	cmp bx, MAX_HEIGHT
	pop bx
	jg @@false

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