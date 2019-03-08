model tiny

.code
ORG 100h

start:

include macro.asm
include procs.asm

error_msg   	db "Some error with args. Check help (/?)", "$"
alr_inst_msg   	db "Program is already resident and cannot be reinstalled", "$"
help_msg    	db "This programm installs and uninstalls (if possible) resident program.", 0Dh, 0Ah, "Resident is hooked to INT 2F.", 0Dh, 0Ah, "$"
help_instl_msg  db "/i - install (if not already), using INT 21 -> 31f;", 0Dh, 0Ah, "$"
help_help_msg   db "/? - this help.", 0Dh, 0Ah, "$"
output			db 4 dup(0), '$'
SPACE    = 20h
QUESTION = 3Fh
SLASH    = 2Fh
INSTL    = 69h
TSR_FUNC = 31h
SEMICOLON = 3Ah
SGNT_CHK = 0c0h
SIGNATURE = 0ABCDh

main:
	jmp init

	old_vector		db 2 dup(?)
	old_2fh 		dd ?
	has_run 		db 0
	hello      		db 'Hello from resident! :)', 0Dh, 0Ah, '$'

new_2fh:
	cmp byte ptr cs:has_run, 0
	je .print_installed
	jmp .func_switch
.print_installed:
	push ax
	push dx
	call_print cs:hello
	inc byte ptr cs:has_run
	pop dx
	pop ax
.func_switch:
	cmp al, SGNT_CHK
	je  .signature_check
	jmp .pass
.signature_check: 
	rol dx, 8
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

	mov bl, INSTL
	cmp bl, [si*1]
	je install

	jmp .error
	
install:
	xor ax, ax
	mov al, SGNT_CHK
	mov dx, SIGNATURE
	int MULTIPLEX
	rol dx, 8
	cmp dx, SIGNATURE
	je .installed_already

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
	call_print help_instl_msg
	call_print help_help_msg
	jmp .ex_it
	
.installed_already:
	call_print alr_inst_msg
	jmp .ex_it
	
.error:
	call_print error_msg

.ex_it:
	call_exit


end start

