PRINT_STR	= 09h
WRITE 		= 40h ;bx - file handler, cx - length, dx - buffer. ax - len\error
EXIT 		= 4Ch
STDOUT 		= 1
SYSCALL 	= 21h

jmp main

call_get_vector macro intrpt
	mov ah, GIVE_VECTOR
	mov al, intrpt
	int SYSCALL ;ES:BX -> current interrupt handler
endm

call_print macro buffer
	mov		ah,   PRINT_STR
	mov  	dx,	  offset buffer
	int 	SYSCALL
endm

call_print_reg macro reg
	mov		ah,   PRINT_STR
	mov  	dx,	  reg
	int 	SYSCALL
endm

call_write macro buffer, lbuffer
	mov ah, WRITE
    mov bx, STDOUT
    xor ch, ch
    mov cl, lbuffer   ; CX: number of bytes to write
    mov dx, buffer    ; DS:DX -> data to write
    int SYSCALL
endm

call_write_big macro buffer, lbuffer
	mov ah, WRITE
    mov bx, STDOUT
    mov cx, lbuffer   ; CX: number of bytes to write
    mov dx, buffer    ; DS:DX -> data to write
    int SYSCALL
endm

call_exit macro
	mov ah, EXIT
    int SYSCALL
endm

call_check_installed macro
	call_multiplex RSD_NUM, RSD_NUM_STATUS
	cmp al, RSD_INSTALLED
	je .installed_already
endm

call_multiplex macro num, func
	mov ah, num
	mov al, func
	int MULTIPLEX
endm