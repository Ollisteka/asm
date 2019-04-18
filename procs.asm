jmp main

reg_to_str: ;->AX
    mov di, offset output
    mov cl, 4
rts1: 
	cmp cl, 2
	jne rts1_2
	inc di
rts1_2:
    rol ax, 4
    mov bl, al
    and bl, 0Fh          ; only low-Nibble
    add bl, 30h          ; convert to ASCII
    cmp bl, 39h          ; above 9?
    jna rts2
    add bl, 7            ; "A" to "F"
rts2: mov [di], bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz rts1              ; jump if cl is not equal 0 (zeroflag is not set)
    
	inc di
    ret


append_char:
	cmp al, CR
	je skip_enter
		mov [di*1], al
		ret
	skip_enter:
		mov dl, 0
		mov [di*1], dl
		ret


install:
	call save_vectors
	mov dx, offset new_09h
	call set_vector
	ret


uninstall:
	mov dx, word ptr old_09h
	push ds
	push word ptr old_09h + 2
	pop ds
	call cs:set_vector
	pop ds
	ret


save_vectors:
	push es

	push 0
	pop es
	mov bx, word ptr es:[09h * 4] ; загружаю адрес текущего вектора прерывания (смещение)
	mov es, word ptr es:[09h * 4 + 2] ; загружаю адрес текущего вектора прерывания (сегмент)
	
	mov word ptr old_09h,   bx
    mov word ptr old_09h+2, es
	pop es
	
	ret
	
set_vector:
	mov ah, 25h
	mov al, 09h
	int SYSCALL
	ret

