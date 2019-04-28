	old_09h dd ?
	BUF_LEN = 5
	kb_buffer dw BUF_LEN dup(0), 0
	head db 0
	tail db 0
	ENTER_SC = 1ch
	ENTER_RELEASE_SC = 9ch

new_09h:
	write_to_tail:
		push ax bx cx dx si
		xor ax, ax
		in al, 60h
		
		cmp al, ENTER_SC
		je @@unlock
		cmp al, ENTER_RELEASE_SC
		je @@unlock

		;код отжатия?
		mov cx, BUF_LEN
		mov bx, 0
		mov si, offset kb_buffer
		@@check_release:
			mov dx, [si+bx]
			cmp dl, al ; удерживаем клавишу
			je @@skip_circling
			or dl, 80h
			cmp dl, al ; отжали клавишу
			je @@key_released
			inc bx
			loop @@check_release
		jmp @@check_buff_size

		@@key_released:
			@@shift_left:
				mov dx, [si+bx+1]
				mov [si+bx], dx
				inc bx
				loop @@shift_left
			dec [tail]

		jmp @@unlock

		@@check_buff_size:
		;буфер полон?
		cmp [tail], BUF_LEN
		je @@skip_circling
		
		mov bx, offset kb_buffer
		add bl, [tail]
		mov [bx], ax
		inc [tail]

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
		pop si dx cx bx ax
		iret