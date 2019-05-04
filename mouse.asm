model tiny

.code
ORG 100h
locals @@

start:
	include macro.asm
	include procs.asm
	include paint.asm
	include mhand.asm
	
output db 4 dup(0), 20h, '$'
	
mode_num		db 0
page_num		db 0

field_color		db 1
circle_color    db 2

upper_left_x   dw 150d
upper_left_y   dw 115d

center_x	   dw  ?
center_y	   dw  ?

prev_x 		dw ?
prev_y 		dw ?

VIDEO_SEG = 0A000h
MAX_WIDTH = 640d
MAX_HEIGHT = 350d

LINE_WIDTH = 5d

FIELD_WIDTH = 80d
FIELD_HEIGHT = 30d

CIRCLE_RADIUS = 20d



main:
	read_byte_lowmem ACTIVE_PAGE
	push ax

	read_byte_lowmem DISPLAY_MODE
	push ax
	
	mov ah, 00h
	mov al, 10h
	;or al, 80h
	int 10h
	
	mov ax, [upper_left_x]
	add ax, 2
	mov [center_x], ax
	mov ax, [upper_left_y]
	add ax, FIELD_HEIGHT / 2
	mov [center_y], ax
	
	call change_color
	mov al, [field_color]
	call draw_rectangle
	
	call change_color_circle
	call draw_filled_circle
	
	mov ax, 1
	int 33h
	
	mov ax, 3
	int 33h
	
	mov [prev_x], cx
	mov [prev_y], dx
	
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
    mov         cx, 01001b
    mov         dx, offset mouse_handler
    int         33h
	ret

end start