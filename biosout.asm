.model tiny
.code
.386
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
WIDTH_OFFSET    db (80-31)/2
COLUMN_NUM		db ?
first_row_xor   dw 00001111b
MODE_MASK = 1
PAGE_MASK = 2
BLINK_MASK = 4
HEIGHT_OFFSET = (25 - 16)/2
DISPLAY_MODE = 0449h
ACTIVE_PAGE = 0462h
COLUMN_NUM_LM = 044ah

main:
	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	jne .parse_lp
	jmp .help
.parse_lp:
	call skip_spaces
	
	cmp cx, 2
	jae @@2
	
	mov al, MODE_MASK
	or al, PAGE_MASK
	test byte ptr flags, al
	jz .error

	jmp prog
	
@@2:
	mov bl, '/'
	cmp [si*1], bl
	je @@3
	jmp .error
@@3:
	call move_pointer
	mov bl, '?'
	cmp bl, [si*1]
	je .help

try_mode_parse:
	mov bl, 'm'
	cmp bl, [si*1]
	jne try_page_parse
	call_arg_parse MODE_MASK, mode_num
	cmp byte ptr mode_num, 1
	ja jmp_to_lp
	mov byte ptr WIDTH_OFFSET, (40-31)/2
jmp_to_lp:
	jmp .parse_lp

try_page_parse:
	mov bl, 'p'
	cmp bl, [si*1]
	jne try_blink_parse
	call_arg_parse PAGE_MASK, page_num
	jmp .parse_lp
	
try_blink_parse:
	mov bl, 'b'
	cmp bl, [si*1]
	jne .error
	jmp_if_bit_set BLINK_MASK, .double_arg_error
	or byte ptr flags, BLINK_MASK
	call move_pointer
	jmp .parse_lp
	
prog:
	;save display
	mov si, ACTIVE_PAGE
	call read_byte_lm
	push ax

	mov si, DISPLAY_MODE
	call read_byte_lm
	push ax

	mov ah, 00h
	mov al, byte ptr mode_num
	;or al, 80h
	int 10h
	
	mov si, COLUMN_NUM_LM
	call read_word_lm
	mov byte ptr COLUMN_NUM, al
	
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

	;hide cursor
	mov ah, 02h
	mov bh, byte ptr page_num
	xor dx, dx
	mov dh, byte ptr COLUMN_NUM
	shl dh, 2
	int 10h
	
	xor dx, dx
	add dh, HEIGHT_OFFSET
	add dl, WIDTH_OFFSET
	
	mov si, 256
	mov al, 0 ; символ
	mov ah, 00011111b ; атрибут
	mov bh, byte ptr page_num 
	
cloop:
	cmp dh, 15 + HEIGHT_OFFSET
	je clp2
	mov ah, 00011111b
clp2:
	cmp dh, 2 + HEIGHT_OFFSET
	je third_row_lp
	cmp dh, 0 + HEIGHT_OFFSET
	je first_row_lp
	jmp clp1

first_row_lp:
	push dx
	shr dx, 1
	and dx, 000Fh ;номер символа в строке
	mov byte ptr fg_color, dl
	and dl, byte ptr first_row_xor
	xor dl, byte ptr first_row_xor
	mov byte ptr bg_color, dl
	create_attribute bg_color, fg_color
	pop dx
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
	xor ax, ax
	int 16h
	pop ax
	
	;restore display
	pop ax
	mov ah, 00h
	int 10h
	pop ax
	mov ah, 05h
	int 10h
	
	jmp .ex_it
	
.help:
	call_print help_msg
	call_print help_mode_msg1
	call_print help_mode_msg2
	call_print help_mode_msg3
	call_print help_mode_msg4
	call_print help_page_msg1
	call_print help_page_msg2
	call_print help_page_msg3
	call_print help_blink_msg
	call_print help_help_msg
	jmp .ex_it

.double_arg_error:
	call_print double_arg_err_msg
	jmp .ex_it
	
.error:
	call_print error_msg

.ex_it:
	call_exit
	
end start