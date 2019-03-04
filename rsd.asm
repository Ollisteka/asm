model tiny

.code
ORG 100h

start:

include macro.asm
include procs.asm

intrpt_str 		db "interrupt call", "$"
func_str   		db "function call", "$"
error_msg   	db "Some error with args. Check help (/?)", "$"
alr_inst_msg   	db "Program is already resident", "$"
help_msg    	db "This programm creates resident, using one of the ways:", 0Dh, 0Ah, "$"
help_int_msg    db "/i - TSR, using 27h DOS interrupt", 0Dh, 0Ah, "$"
help_func_msg   db "/f - TSR, using 31h function of 21h DOS interrupt", 0Dh, 0Ah, "$"
buffer			db 8 dup(0)
old_vector		db 2 dup(?)
old_2fh 		dd ?
has_run 		db 0
output			db 4 dup(0), '$'
SPACE    = 20h
QUESTION = 3Fh
SLASH    = 2Fh
FUNC     = 66h
INTRPT   = 69h
TSR_INT  = 27h ; CS - PSP segment, DX: address at which mext program can be loaded
TSR_FUNC = 31h
RSD_NUM  = 0c0h
SEMICOLON = 3Ah


main:
	jmp init
	hello      		db 'Hello, ASM!', 0Dh, 0Ah
	lhello  =    	$ - hello
new_2fh:
	cmp byte ptr cs:has_run, 0
	je .print_installed
	jmp .cont
.print_installed:
	push ax
	mov si, offset cs:hello
	call_write_big si, lhello
	pop ax
	inc byte ptr cs:has_run
.cont:
	cmp al, RSD_NUM_STATUS
	jne .pass	;не функция определения установлена программа или нет
	cmp ah, RSD_NUM
	je .catch ; это наш номер, нужно сказать, что мы установлены

	jmp .pass ; номер не наш, передать управление старому обработчику
.catch:
	mov al, RSD_INSTALLED
	jmp .iret
.pass:	
	jmp dword ptr cs:old_2fh
.iret:
	iret

init:
	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	jne .l1
	jmp .help
.l1:
	call skip_spaces
	
	cmp cl, 2
	je .l2
	jmp .error
.l2:
	mov bl, SLASH
	cmp bl, [si*1]
	je .l3
	jmp .error
.l3:
	inc si
	
	mov bl, QUESTION
	cmp bl, [si*1]
	je .help

	mov bl, INTRPT
	cmp bl, [si*1]
	je interrupt
	
	mov bl, FUNC
	cmp bl, [si*1]
	je function

	jmp .error
	

interrupt:
	call_check_installed
	;call_print intrpt_str
	call set_vectors
	mov dx, offset init
	add dx, 2
	int TSR_INT
	
function:
	call_check_installed
	;call_print func_str
	
	call set_vectors

	xor dx, dx	
	mov dx, offset init
	shr dx, 4
	inc dx
	xor ax, ax
	mov ah, TSR_FUNC
	mov al, 0 ;return code of this program

	int SYSCALL
	
.help:
	call_print help_msg
	call_print help_int_msg
	call_print help_func_msg
	jmp .ex_it
	
.installed_already:
	call_print alr_inst_msg
	jmp .ex_it
	
.error:
	call_print error_msg

.ex_it:
	call_exit


end start

