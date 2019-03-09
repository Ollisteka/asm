model tiny

.code
ORG 100h

start:

include macro.asm
include procs.asm

error_msg   	db "Some error with args. Check help (/?)", "$"
alr_inst_msg   	db "Program is already resident and cannot be reinstalled", "$"
uninst_err_msg  db "Cannot uninstall", "$"
vec_equal_msg   db "Deinstallation finished successfully. ", "$"
vec_not_eq_msg  db "Vectors not equal. ", "$"
help_msg    	db "This programm installs and uninstalls (if possible) resident program.", 0Dh, 0Ah, "Resident is hooked to INT 2F.", 0Dh, 0Ah, "$"
help_instl_msg  db "/i - install (if not already), using INT 21 -> 31f;", 0Dh, 0Ah, "$"
help_un_msg1    db "/u - uninstall, using INT 21 -> 49f.", 0Dh, 0Ah, "$"
help_un_msg2    db "     Possible, if current 2F interrupt vector is the same, as in the program.", 0Dh, 0Ah, "$"
help_un_msg3    db "     How it works:", 0Dh, 0Ah, "$"
help_un_msg4    db "       - Frees the memory from handler and its DOS Environment;", 0Dh, 0Ah, "$"
help_un_msg5    db "       - Sets previous value of 2F interrupt vector.", 0Dh, 0Ah, "$"
help_help_msg   db "/? - this help.", 0Dh, 0Ah, "$"
output			db 4 dup(0), '$'
SPACE    = 20h
QUESTION = 3Fh
SLASH    = 2Fh
INSTL    = 69h
UNINSTL  = 75h
SEMICOLON = 3Ah
SGNT_CHK  = 0c0h
GET_HANDL_INT_VEC = 0c1h
GET_OLD_INT_VEC = 0c2h
SIGNATURE = 0ABCDh

main:
	jmp init

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
	
	cmp al, GET_OLD_INT_VEC
	je  .get_old_int_vector
	
	cmp al, GET_HANDL_INT_VEC
	je .get_handler_int_vect
	
	jmp .pass
	
.signature_check: 
	rol dx, 8
	jmp .iret
	
.get_old_int_vector:
	mov bx,  word ptr cs:old_2fh
    mov es,  word ptr cs:old_2fh+2
	jmp .iret
	
.get_handler_int_vect:
	mov bx, offset new_2fh
	push cs
	pop es
	jmp .iret
.pass:
	jmp cs:old_2fh
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
	jne .l4
	jmp .help
.l4:
	mov bl, INSTL
	cmp bl, [si*1]
	je install
	
	mov bl, UNINSTL
	cmp bl, [si*1]
	je uninstall

	jmp .error
	
install:
	xor ax, ax
	mov al, SGNT_CHK
	mov dx, SIGNATURE
	int MULTIPLEX
	rol dx, 8
	cmp dx, SIGNATURE
	jne .inst_1
	jmp .installed_already
.inst_1:
	call set_vectors

	xor dx, dx	
	mov dx, offset init
	shr dx, 4
	inc dx
	xor ax, ax
	mov ah, 31h
	mov al, 0 ;return code of this program

	int SYSCALL
	
uninstall:
	mov al, GET_HANDL_INT_VEC
	int MULTIPLEX
	
	mov word ptr old_2fh,   bx  ;my handler offset
    mov word ptr old_2fh+2, es	;my handler segment
	
	call_get_vector MULTIPLEX

	cmp bx, word ptr old_2fh
	jne .vec_neq
	mov ax, es
	cmp ax, word ptr old_2fh+2
	jne .vec_neq
	
	nop
	
	mov al, GET_OLD_INT_VEC
	int MULTIPLEX
	mov word ptr new_2fh,   bx  ;old handler offset
    mov word ptr new_2fh+2, es	;old handler segment
	
	push ds
	
	mov ah, SET_VECTOR
	mov al, 2fh
	lds dx, dword ptr cs:new_2fh
	int SYSCALL
	
	pop ds
	
	mov es, word ptr old_2fh+2
	mov es, es:002ch
	call free_memory
	
	mov es, word ptr old_2fh+2
	call free_memory
	
	call_get_vector 2fh
	call print_vector
	call print_newl
	
	call_print vec_equal_msg
	
	jmp .ex_it

.vec_neq:
	call_print vec_not_eq_msg
	jmp .cant_uninstall
	
	jmp .ex_it
	
.help:
	call_print help_msg
	call_print help_instl_msg
	call_print help_un_msg1
	call_print help_un_msg2
	call_print help_un_msg3
	call_print help_un_msg4
	call_print help_un_msg5
	call_print help_help_msg
	jmp .ex_it
	
.installed_already:
	call_print alr_inst_msg
	jmp .ex_it
	
.cant_uninstall:
	call_print uninst_err_msg
	jmp .ex_it
	
.error:
	call_print error_msg

.ex_it:
	call_exit


end start

