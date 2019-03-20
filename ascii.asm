.model tiny
.code
org 100h

start:

include macro.asm
newl  db 13, 10, '$'

main:
xor ax, ax
xor cx, cx
xor dx, dx
mov ah, 02h
mov bx, 0
mov cx, 16
columns:
	mov bx, cx
    mov cx, 16
rows:
	int 21h
	inc dx
	
	;push ax
	;xor ax, ax
	;int 16h
	;pop ax
	
	loop rows

	push dx
	push ax
    call_print newl
	pop ax
	pop dx
 
    mov cx, bx
    loop columns      
	
	mov ax, 4C00h
    int 21h
	
end start