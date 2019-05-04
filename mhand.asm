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
	
	
drag_handler:
	mov [prev_x], cx
	mov [prev_y], dx
	jmp @@exit
	
@@exit:
	pop ds
	retf


;;;;;
movement_handler:
	test bx, 1 ; нажата ЛКМ
	jnz drag_handler
	;двигаем шарик
	
	cmp dx, [prev_y]
	ja try_move_down
	
	cmp dx, [prev_y]
	jb try_move_up
	
	cmp cx, [prev_x]
	ja try_move_right
	
	cmp cx, [prev_x]
	jb try_move_left
	
	jmp move_ret
	
try_move_down:	
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_y]
	inc bx
	call can_move_y_axis
	jz move_ret
	
	@@can_move_down:
		call erase_circle
		inc [center_y]	
		jmp repaint_circle
	
try_move_up:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_y]
	dec bx
	call can_move_y_axis
	jz move_ret

	@@can_move_up:
		call erase_circle
		dec [center_y]	
		jmp repaint_circle
	
try_move_right:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	inc bx
	call can_move_x_axis
	jz move_ret
		
	@@can_move_right:
		call erase_circle
		inc [center_x]
		jmp repaint_circle
		
try_move_left:
	mov [prev_x], cx
	mov [prev_y], dx
	mov bx, [center_x]
	dec bx
    call can_move_x_axis
	jz move_ret
		
	@@can_move_left:
		call erase_circle
		dec [center_x]
		jmp repaint_circle
	
repaint_circle:
	call draw_filled_circle

move_ret:	
	jmp @@exit
endp mouse_handler

erase_circle:
	call draw_black_circle
	mov al, [field_color]
	call draw_rectangle
	call show_cursor
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