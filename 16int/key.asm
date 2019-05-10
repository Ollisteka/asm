.model tiny
.code
org 100h

start:

include macro.asm
include procs.asm

MAX_LEN = 2
CR = 0Dh
ESCAPE = 1bh

buffer db MAX_LEN, 0, MAX_LEN dup(0)
output db 8 dup (0), CR, 0AH, '$'

main:
_loop:
	xor ax, ax
	int 16h
	
	cmp al, ESCAPE
	je ex_it
	
	call reg_to_str
	call append_char
	call_print output

	jmp _loop
	
ex_it:
	call_exit
	

append_char:
	cmp al, CR
	je skip_enter
		mov [di*1], al
		ret
	skip_enter:
		mov dl, 0
		mov [di*1], dl
		ret
end start