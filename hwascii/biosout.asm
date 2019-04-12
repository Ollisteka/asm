.model tiny
.code

org 100h
locals @@

start: 
include macro.asm
include procs.asm

error_msg   	db "Some error with args. Check help (/?).", "$"
double_arg_err_msg  db "You can't use the same argument twice", "$"
help_msg    	db "This programm prints ASCII table on the screen", 0Dh, 0Ah, "$"
help_mode_msg1  db "/m - specify, which mode to use (default 0):", 0Dh, 0Ah, "$"
help_mode_msg2  db "     0, 1 - 16 colors, 40x25 (25 rows with 40 symbols) with gray\without", 0Dh, 0Ah, "$"
help_mode_msg3  db "     2, 3 - 16 colors, 80x25 with gray\without", 0Dh, 0Ah, "$"
help_mode_msg4  db "     7 - 3 colors, 80x25", 0Dh, 0Ah, "$"
help_page_msg1  db "/p - specify, on which page to print (default 0):", 0Dh, 0Ah, "$"
help_page_msg2  db "     0-7 for modes 0 and 1.", 0Dh, 0Ah, "$"
help_page_msg3  db "     0-3 for modes 2 and 3.", 0Dh, 0Ah, "$"
help_blink_msg  db "/b - if set, enables blinking letters. Otherwise enables background intensity;", 0Dh, 0Ah, "$"
help_help_msg   db "/? - this help.", "$"
mode_num		db 0
page_num		db 0
flags   		db 0  ;X|X|X|X|X|BLINK_ENABLED|PAGE_PARSED|MODE_PARSED|
fg_color 		db ?
bg_color 		db ?
third_row		db 0
WIDTH_OFFSET	db (80-31)/2
first_row_xor	dw 00001111b
current_mode_page_str db "Current mode is X, page is Y"
current_mp_str_len = $ - current_mode_page_str
current_mode_offset = 12*2
current_page_offset = 1*2
MODE_MASK = 1
PAGE_MASK = 2
BLINK_MASK = 4
HEIGHT_OFFSET = (25 - 16)/2
DISPLAY_MODE = 0449h
ACTIVE_PAGE = 0462h
COLUMN_NUM_LM = 044ah
ROWS_NUM_LM = 0484h

main:
	include argpars.asm
prog:
	cmp byte ptr mode_num, 1
	ja @@skip_width_change
	mov byte ptr WIDTH_OFFSET, (40-31)/2
	;save display
@@skip_width_change:	
	read_byte_lowmem ACTIVE_PAGE
	push ax
	add ax, '0'

	read_byte_lowmem DISPLAY_MODE
	push ax
	add ax, '0'
	
	call clear_screen
	call hide_cursor

	read_byte_lowmem ROWS_NUM_LM
	shr al, 1
	call print_mode_page
	call wait_for_key_press
	
	;set new mode\page
	mov ah, 00h
	mov al, byte ptr mode_num
	;or al, 80h
	int 10h
	
	mov ah, 05h
	mov al, byte ptr page_num
	int 10h
	
	mov ax, 1003h
	xor bx, bx
	jmp_if_bit_not_set BLINK_MASK, @@skip_inc
	and byte ptr first_row_xor, 00000111b
	inc bl
@@skip_inc:
	int 10h

	xor ax, ax
	mov al, HEIGHT_OFFSET
	dec al
	call print_mode_page
	call hide_cursor
	
	xor dx, dx
	add dh, HEIGHT_OFFSET
	add dl, WIDTH_OFFSET
	
	mov si, 256
	mov al, 0 ; символ
	mov ah, 00011111b ; атрибут
	
cloop:
	cmp dh, 15 + HEIGHT_OFFSET ; дошли до края
	je @@skip_color_set
	mov ah, 00011111b
@@skip_color_set:
	cmp dh, 2 + HEIGHT_OFFSET
	je third_row_lp
	cmp dh, 0 + HEIGHT_OFFSET
	je first_row_lp
	jmp clp1

first_row_lp:
	call create_first_row_color
	jmp clp1

third_row_lp:
	mov ah, byte ptr third_row
	add byte ptr third_row, 10000b
	jmp_if_bit_not_set BLINK_MASK, clp1
	and byte ptr third_row, 01111111b
clp1:
	call calc_address
	stosw

	inc dl  ; увеличиваем столбец

	push ax
	inc al
	test al, 0Fh
	jz @@skip_last_space
	pop ax

	push ax 
	call calc_address
	mov al, 20h
	stosw
	
	inc dl  ; увеличиваем столбец
	
@@skip_last_space:
	pop ax
	inc al
	test al, 0Fh
	jnz continue_loop
	
	inc dh ; увеличиваем строчку
	mov dl, WIDTH_OFFSET
	
	cmp dh, 15 + HEIGHT_OFFSET
	jne continue_loop
	mov ah, 10001100b

continue_loop:
	dec si
	jnz cloop
	
	push ax
	call wait_for_key_press
	pop ax
	
	;restore display
	pop ax
	mov ah, 00h
	
	int 10h
	pop ax

	mov ah, 05h
	int 10h

	jmp .ex_it

.ex_it:
	call_exit
	
end start