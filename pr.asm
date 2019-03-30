.model tiny
.code
org 100h
locals @@

_start:
	mov ax, 4
	int 10h
	
	mov ax, 0b800h
	mov es, ax
	mov ax, 5555h
	mov di, 400+40-1
	stosw
	
	add di, 78
	stosw
	add di, 78
	stosw
	
	add di, 400+40-1+2000h
	stosw
	add di, 78
	stosw
	add di, 78
	stosw

	xor ax, ax
	int 16h
	mov ax, 3
	int 10h
	
	ret
end _start