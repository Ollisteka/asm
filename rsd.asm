model tiny

.data

include macro.asm
include procs.asm

hello      		db 'Hello, ASM!', '$'
intrpt_str 		db "interrupt call", "$"
func_str   		db "function call", "$"
error_msg   	db "Some error with args. Check help (/?)", "$"
help_msg    	db "This programm creates resident, using one of the ways:", 0Dh, 0Ah, "$"
help_int_msg    db "/i - TSR, using 27h DOS interrupt", 0Dh, 0Ah, "$"
help_func_msg   db "/f - TSR, using 31h function of 21h DOS interrupt", 0Dh, 0Ah, "$"
SPACE    = 20h
QUESTION = 3Fh
SLASH    = 2Fh
FUNC     = 66h
INTRPT   = 69h
TSR_INT  = 27h ; CS - PSP segment, DX: address at which mext program can be loaded
TSR_FUNC = 31h
PARAGRAPH_SIZE = 16

.CODE 
ORG 100h
start:
	;call_write 81h, ds:[0080h]
	jmp init
hello_rsd:
	push 	ax
	mov		ah,   PRINT_STR
	mov  	dx,	  offset hello	;pointer to str
	int 	SYSCALL
	pop 	ax
	
	ret

init:
	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	je .help

	call skip_spaces
	
	cmp cl, 2
	jne .error
	
	mov bl, SLASH
	cmp bl, [si*1]
	jne .error
	inc si
	
	mov bl, QUESTION
	cmp bl, [si*1]
	je .help

	mov bl, INTRPT
	cmp bl, [si*1]
	je .interrupt
	
	mov bl, FUNC
	cmp bl, [si*1]
	je .function

	jmp .error
	

.interrupt:
	call_print intrpt_str
	mov dx, offset init
	int TSR_INT
	
.function:
	call_print func_str
	xor ax, ax
	xor dx, dx
	
	mov ax, offset init
	mov dl, PARAGRAPH_SIZE
	div dl
	xor dx, dx
	mov dl, al
	cmp ah, 0
	je .cont
	inc dl

	.cont:
	xor ax, ax
	mov ah, TSR_FUNC
	mov al, 0 ;return code of this program

	int SYSCALL
	
.help:
	call_print help_msg
	call_print help_int_msg
	call_print help_func_msg
	jmp .ex_it
	
.error:
	call_print error_msg

.ex_it:
	call_exit

end start

