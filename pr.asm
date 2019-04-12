.model tiny
.code
org 100h

start:

include macro.asm

MAX_LEN = 5

buffer db MAX_LEN, 5, 61, 62, 63, 64, 65, 0

main:
	xor ax, ax
	mov ah, 0Ah
	mov dx, offset buffer
	int 21h
	
	xor bx, bx
	mov bl, byte ptr buffer + 1
	mov byte ptr buffer + [bx] + 2, '$'
	mov byte ptr buffer + 1, 0Ah	
	
	mov	ah,   09h
	mov dx,	  offset buffer
	inc dx
	int 21h
	
	call_exit
end start