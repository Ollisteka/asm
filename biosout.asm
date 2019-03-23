.model tiny
.code
.386
org 100h
locals @@

start: 
include macro.asm
include procs.asm

error_msg   	db "Some error with args. Check help (/?)", "$"
double_arg_err_msg  db "You can't use the same argument twice", "$"
help_msg    	db "This programm prints ASCII table on the screen", 0Dh, 0Ah, "$"
help_mode_msg1  db "/m - specify, which mode to use (default 0):", 0Dh, 0Ah, "$"
help_mode_msg2  db "     0, 1 - 16 colors, 40x25 (25 rows with 40 symbols) with gray\without", 0Dh, 0Ah, "$"
help_mode_msg3  db "     2, 3 - 16 colors, 80x25 with gray\without", 0Dh, 0Ah, "$"
help_page_msg1  db "/p - specify, on which page to print (default 0):", 0Dh, 0Ah, "$"
help_page_msg2  db "     0-7 for modes 0 and 1.", 0Dh, 0Ah, "$"
help_page_msg3  db "     0-3 for modes 2 and 3.", 0Dh, 0Ah, "$"
help_help_msg   db "/? - this help.", 0Dh, 0Ah, "$"
mode_num		db 0
page_num		db 0
flags   		db 0  ;X|X|X|X|X|X|PAGE_PARSED|MODE_PARSED|
SPACE    = 20h
QUESTION = 3Fh
SLASH    = 2Fh
MODE     = 6Dh
PAGENUM  = 70h
MODE_MASK = 1
PAGE_MASK = 2

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
	mov bl, SLASH
	cmp bl, [si*1]
	je @@3
	jmp .error
@@3:
	call move_pointer
	mov bl, QUESTION
	cmp bl, [si*1]
	je .help

try_mode_parse:
	mov bl, MODE
	cmp bl, [si*1]
	jne try_page_parse
	call_arg_parse MODE_MASK, mode_num

try_page_parse:
	mov bl, PAGENUM
	cmp bl, [si*1]
	jne .error
	call_arg_parse PAGE_MASK, page_num
	
prog:
	;save display
	mov ah, 0fh   ; AH = number of character columns
	int 10h  	  ; AL = display mode
                  ; BH = active page
	push bx ax

	mov ah, 00h
	mov al, byte ptr mode_num
	int 10h
	
	mov ah, 05h
	mov al, byte ptr page_num
	int 10h

	xor dx, dx
	
	mov si, 256
	mov al, 0 ; символ
	mov ah, 9 ; функция
	mov cx, 1 ; число повторений
	mov bh, byte ptr page_num 
	mov bl, 00010111b ; атрибут
	
cloop:
	int 10h
	
	push ax
	mov ah, 2
	inc dl
	int 10h ; переместить курсор
	
	test al, 0Eh
	jnz @@skip_last_space
	
	mov ax, 0920h
	int 10h ; напечатать пробел
@@skip_last_space:
	pop ax
	inc al
	test al, 0Fh
	jnz continue_loop
	
	push ax
	mov ah, 2
	inc dh ;новая колонка
	mov dl, 0
	int 10h ;переводим куросор на новую строку
	pop ax
	
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
	shr ax, 0Fh
	mov ah, 05h
	int 10h
	
	jmp .ex_it
	
.help:
	call_print help_msg
	call_print help_mode_msg1
	call_print help_mode_msg2
	call_print help_mode_msg3
	call_print help_page_msg1
	call_print help_page_msg2
	call_print help_page_msg3
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