jmp main

change_color proc
	inc [field_color]
	and [field_color], 1111b
	jnz @@exit
	inc [field_color]
@@exit:
	ret
endp change_color

change_color_circle proc
	inc [circle_color]
	and [circle_color], 1111b
	jnz @@exit
	inc [circle_color]
@@exit:
	ret
endp change_color_circle

draw_filled_circle proc
	mov si, CIRCLE_RADIUS
	mov bl, [circle_color]
@@circle_loop:
	mov cx, [center_x]
	mov dx, [center_y]
	call draw_circle
	dec si
	jnz @@circle_loop
	ret
endp draw_filled_circle

draw_circle proc
; Алгоритм рисования круга, используя только сложение, вычитание и сдвиги.
; (упрощенный алгоритм промежуточной точки)
; Ввод: SI = радиус, AX = номер столбца центра круга, BX = номер строки
; центра круга
; модифицирует DI, DX
	push si cx dx
	xor	di, di		; DI - относительная X-координата текущей точки
	dec	di		    ; (SI - относительная Y-координата, начальное значение - радиус)
	mov	ax, 1		 
	sub	ax, si		; AX - наклон (начальное значение 1-Радиус)
	;SI + DI = RADIUS
@@circle_loop:
	inc	di		    ; следующий X (начальное значение - 0)
	cmp	di, si		; цикл продолжается, пока X <= Y
	ja	@@exit

	pop	dx		; DX = номер строки центра круга X-координата
	pop	cx		; CX = номер столбца центра круга Y-координата

	push cx dx ax
	
	mov al, bl

	add	dx, di		; вывод восьми точек на окружности:
	add	cx, si
	call	draw_pixel	; центр_X + X, центр_Y + Y
	sub	cx, si
	sub	cx, si
	call	draw_pixel	; центр_X + X, центр_Y - Y
	sub	dx, di
	sub	dx, di
	call	draw_pixel	; центр_X - X, центр_Y - Y
	add	cx, si
	add	cx, si
	call	draw_pixel	; центр_X - X, центр_Y + Y
	sub	cx, si
	add	cx, di
	add	dx, di
	add	dx, si
	call	draw_pixel	; центр_X + Y, центр_Y + X
	sub	cx, di
	sub	cx, di
	call	draw_pixel	; центр_X + X, центр_Y - X
	sub	dx, si
	sub	dx, si
	call	draw_pixel	; центр_X - Y, центр_Y - X
	add	cx, di
	add	cx, di
	call	draw_pixel	; центр_X - Y, центр_Y + X
	
	pop ax

	test ax, ax		
	js	slop_negative
	mov	dx, di   	; если наклон положительный
	sub	dx, si
	shl	dx, 1
	inc	dx
	add	ax, dx		; наклон  = наклон + 2(X - Y) + 1
	dec	si		    ; Y = Y - 1
	jmp	@@circle_loop
slop_negative:		; если наклон отрицательный
	mov	dx, di
	shl	dx, 1
	inc	dx
	add	ax, dx		; наклон = наклон + 2X + 1
	jmp	@@circle_loop	; и Y не изменяется
@@exit:
	pop	dx cx si
	ret
	
endp draw_circle

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
	add bx, FIELD_WIDTH
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
	mov cx, FIELD_HEIGHT + LINE_WIDTH
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
	
draw_black_circle:
	mov al, [circle_color]
	push ax
	
	mov [circle_color], 0
	call draw_filled_circle
	
	pop ax
	mov [circle_color], al
	
	ret
	
	
draw_pixel:
;BH = номер страницы = 0
;СХ = номер столбца
;DX = номер строки
;AL = цвет
    push bx
	xor bx, bx
    mov  ah, 0Ch
    int  10h
	pop bx
	ret
	
get_pixel:
;BH = номер страницы = 0
;СХ = номер столбца
;DX = номер строки
;Выход:
;AL = цвет
    push bx
	xor bx, bx
    mov  ah, 0Dh
    int  10h
	pop bx
	ret
