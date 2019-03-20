.model tiny
.code
org 100h
locals @@

int_08:
	db 0eadh
	old_addr dw 0, 0


_start:
	mov si, 4*8
	mov di, offset old_addr
	push ds
	xor ax, ax
	mov ds, ax
	movsw
	movsw
	push ds
	push es
	pop ds
	pop es
	mov di, 4*8
	mov ax, offset int_08
	cli
	stosw
	mov ax, cs
	stosw
	sti
	