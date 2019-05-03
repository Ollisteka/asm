model tiny

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	include paint.asm
	
mode_num		db 0
page_num		db 0

field_color		db 1

upper_left_x   dw 150
upper_left_y   dw 115

VIDEO_SEG = 0A000h
MAX_WIDTH = 640
MAX_HEIGHT = 350

LINE_WIDTH = 5

FIELD_WIDTH = 325
FIELD_HEIGHT = 125

main:
	read_byte_lowmem ACTIVE_PAGE
	push ax

	read_byte_lowmem DISPLAY_MODE
	push ax
	
	mov ah, 00h
	mov al, 10h
	;or al, 80h
	int 10h
	
	mov ax, 1
	int 33h
	
	mov al, [field_color]
	call change_color
	call draw_rectangle
	
	call add_mouse_handler
	
	call wait_for_key_press
	
	call remove_mouse_handler

	
	pop ax
	mov ah, 00h
	int 10h
	
	pop ax
	mov ah, 05h
	int 10h

	call_exit
	
remove_mouse_handler:	
;ES:DX = 0:0
;CX - маска
	mov         ax,000Ch
    mov         cx,0000h     ; удалить обработчик событий мыши
    int         33h
	ret
	
add_mouse_handler:
;ES:DX = адрес обработчика
;СХ = условие вызова:
;бит 0 — любое перемещение мыши
;бит 1 — нажатие левой кнопки
;бит 2 — отпускание левой кнопки
;бит 3 — нажатие правой кнопки
;бит 4 — отпускание правой кнопки
;бит 5 — нажатие средней кнопки
;бит 6 — отпускание средней кнопки
;СХ = 0000h — отменить обработчик
	mov         ax, 0Ch
    mov         cx, 08h
    mov         dx, offset pkm_handler
    int         33h
	ret

	
pkm_handler:
;АХ = условие вызова
;ВХ = состояние кнопок
;СХ, DX — X- и Y-координаты курсора
;SI, DI — счетчики последнего перемещения по горизонтали и вертикали (единицы измерения для этих счетчиков — мики, 1/200 дюйма)
;DS — сегмент данных драйвера мыши
	push ds cs
	pop ds
	
	mov si, LINE_WIDTH
	mov ax, [upper_left_x]
	mov bx, [upper_left_y]
	jmp @@cmp_loop
@@cmp_loop:
	;Mouse_X-coord == Line_X-coord
	cmp cx, ax
	je @@check_y_range
	
	cmp dx, bx
	je @@check_x_range
	
	inc ax
	inc bx

	dec si
	jnz @@cmp_loop

	jmp @@exit
	
@@check_x_range:
	cmp cx, [upper_left_x]
	jb @@exit
	
	cmp cx, [upper_left_x] + FIELD_WIDTH
	jae @@exit
	
	jmp @@hit
	
	
@@check_y_range:
	cmp dx, [upper_left_y]
	jb @@exit
	
	cmp dx, [upper_left_y] + FIELD_HEIGHT
	jae @@exit
	
	jmp @@hit
	
@@hit:
	mov ax, 2
    int 33h
	xor ax, ax
	mov al, [field_color]
	call draw_rectangle
	call change_color
	mov ax, 1
    int 33h
	
@@exit:
	pop ds
	retf
	
change_color proc
	inc [field_color]
	and [field_color], 1111b
	jnz @@exit
	inc [field_color]
@@exit:
	ret
endp change_color

end start