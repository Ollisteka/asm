model tiny

.code
ORG 100h
locals @@

start:
	include procs.asm
	include macro.asm
	include paint.asm
	
mode_num		db 0
page_num		db 0

field_color		db 1
circle_color    db 2

upper_left_x   dw 150
upper_left_y   dw 115

center_x	   dw  ?
center_y	   dw  ?

prev_x 		dw ?
prev_y 		dw ?

VIDEO_SEG = 0A000h
MAX_WIDTH = 640
MAX_HEIGHT = 350

LINE_WIDTH = 5

FIELD_WIDTH = 325
FIELD_HEIGHT = 125

CIRCLE_RADIUS = 20

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
	
	mov al, [field_color]
	call change_color
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

	
mouse_handler proc
;АХ = условие вызова
;ВХ = состояние кнопок
;СХ, DX — X- и Y-координаты курсора
;SI, DI — счетчики последнего перемещения по горизонтали и вертикали (единицы измерения для этих счетчиков — мики, 1/200 дюйма)
;DS — сегмент данных драйвера мыши
	push ds cs
	pop ds
	
	test ax, 1
	;jnz movement_handler
	
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
	
movement_handler:
	test bx, 1 ; нажата ЛКМ
	jnz drag_handler
	;двигаем шарик
	
	cmp dx, [prev_y]
	ja try_move_up
	
	cmp cx, [prev_x]
	ja try_move_right
	jmp move_ret
	
try_move_up:
	inc [center_y]

	call draw_filled_circle
	
	jmp move_ret
	
try_move_right:
	jmp move_ret

move_ret:	
	mov [prev_x], cx
	mov [prev_y], dx
	jmp @@exit
	
drag_handler:
	mov [prev_x], cx
	mov [prev_y], dx
	jmp @@exit
	
@@exit:
	pop ds
	retf
endp mouse_handler
end start