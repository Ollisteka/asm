jmp main

draw_rectangle:
;AL = цвет
	mov cx, LINE_WIDTH
	mov dx, [upper_left_y]
	call draw_fat_hor_line
	
	mov cx, LINE_WIDTH
	mov dx, [upper_left_y]
	add dx, FIELD_HEIGHT
	call draw_fat_hor_line
	
	mov cx, LINE_WIDTH
	mov bx, [upper_left_x]
	
	call draw_fat_vert_line
	
	mov cx, LINE_WIDTH
	mov bx, [upper_left_x]
	add bx, FIELD_WIDTH - LINE_WIDTH
	call draw_fat_vert_line
	
	ret
	
draw_fat_hor_line proc
;CX = ширина линии
jmp @@skip_first_increment
@@increment_y:
	inc dx
@@skip_first_increment:
	push cx
	mov si, [upper_left_x]	;(4)Начальная Х-координата
	mov cx, FIELD_WIDTH	;(5)Число точек по горизонтали
	call horizontal_line
	pop cx
	loop @@increment_y
	ret
	
endp draw_fat_hor_line
	
horizontal_line:	
    push cx
	mov cx, si	;Х-координата (переменная)
	call draw_pixel
	inc si		;Инкремент Х-координаты
	pop cx
	loop horizontal_line
	ret
	
draw_fat_vert_line proc
;CX = ширина линии
;BX = X-координата
jmp @@skip_first_increment
@@increment_x:
	inc bx
@@skip_first_increment:
	push cx
	mov cx, FIELD_HEIGHT
	mov dx, [upper_left_y]
	call vertical_line
	pop cx
	loop @@increment_x
	ret

endp draw_fat_vert_line
	
vertical_line:	
;BX = X-координата
;CX = высота
;DX = Y-координата
	push cx
	mov cx, bx  ;X-координатаа
	call draw_pixel
	inc dx		;Инкремент Y-координаты
	pop cx
	loop vertical_line
	ret
	
	
fill_screen:
	mov        dx, MAX_HEIGHT 
	mov 	   al, 01
	xor        di,  di
next_line:
	mov        cx, MAX_WIDTH 
fill_row:
	call draw_pixel
	loop fill_row

	dec dx
	jnz next_line
	ret
	
	
draw_pixel:
;BH = номер страницы = 0
;DX = номер строки
;СХ = номер столбца
;AL = цвет
    push bx
	xor bx, bx
    mov  ah, 0Ch
    int  10h
	pop bx
	ret