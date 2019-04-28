.model tiny
.code
org 100h
locals @@


start:

include macro.asm
include procs.asm

MAX_LEN = 2
CR = 0Dh
ESCAPE = 1bh

buffer db MAX_LEN, 0, MAX_LEN dup(0)
output db 8 dup (0), CR, 0AH, '$'
terminate db 0

main:
	jmp init

	old_09h dd ?
	BUF_LEN = 4
	kb_buffer dw BUF_LEN dup(0)
	head db 0
	tail db 0

new_09h:
	write_to_tail:
		push ax bx
		xor ax, ax
		in al, 60h
		mov bx, offset kb_buffer
		add bl, [tail]
		mov [bx], ax
		inc [tail]
		
		cmp [tail], BUF_LEN
		jb @@skip_circling
		mov byte ptr tail, 0

	@@skip_circling:
		cmp al, 1 ;ESCAPE
		jne @@unlock
		
		mov [terminate], 1
	
	@@unlock:
		in al, 61h 
		push ax
		or al, 80h  
		out 61h, al ;set 7th bit and block
		pop ax
		out 61h, al ;restore

		mov al, 20h  ;послать сигнал "конец прерывания" контроллеру прерываний 8259
		out 20h,al

		jmp .iret

	.iret:
		pop bx ax
		iret
	
init:
	call install
_loop:
	cmp [terminate], 0
	jnz ex_it

	xor bx, bx
	mov bl, [head]
	cmp bl, [tail]
	je _loop
	
		add bx, offset kb_buffer
		mov ax, [bx]
		mov di, offset output
		call reg_to_str
		mov ah, PRINT_STR
		mov dx, offset output
		add dx, 3
		int SYSCALL
		
		
		
	inc [head]
	cmp [head], BUF_LEN
	jb _loop
		mov [head], 0
	jmp _loop


ex_it:
	call uninstall
	call_exit
	
end start