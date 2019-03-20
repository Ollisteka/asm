jmp main

MULTIPLEX = 2Fh
RSD_NUM_STATUS = 0
MIN_NUM = 0C0h
MAX_NUM = 0FFh
NUM_FREE = 0
RSD_INSTALLED = 0FFh
GIVE_VECTOR = 35h
SET_VECTOR  = 25h

skip_spaces:
	xor ah, ah
    mov al, [si*1]    ; letter
    mov bl, SPACE
    cmp bl, al
    je skip_char
	.ex:
    ret

    skip_char:
        inc si
        dec cx
		cmp cx, 0
		je .ex
        jmp skip_spaces
		
set_vectors:
	push es

	push 0
	pop es
	
	cli ; запрещаю аппаратные прерывания, чтобы таблица векторов не поменялась
    mov bx, word ptr es:[2fh * 4] ; загружаю адрес текущего вектора прерывания (смещение)
	mov es, word ptr es:[2fh * 4 + 2] ; загружаю адрес текущего вектора прерывания (сегмент)
	
	mov word ptr old_2fh,   bx
    mov word ptr old_2fh+2, es

	call print_vector
	call print_newl

	push 0
	pop es	
	mov word ptr es:[2fh * 4], offset new_2fh ;устанавливаю адрес своего обработчика в таблицу прерываний
	mov word ptr es:[2fh * 4 + 2], cs  ;устанавливаю сегментный адрес своего обработчика в таблицу прерываний
	sti
	
	mov bx, word ptr es:[2fh * 4]
	mov es, word ptr es:[2fh * 4 + 2] 
	
	call print_vector
	
	pop es
	ret
	
print_vector:  ;es:segment bx:offset
	mov ax, es
	call reg_to_str

	mov al, SEMICOLON
	int 29h

	mov ax, bx
	call reg_to_str
	ret
	
print_newl:
	mov al, 0Dh
	int 29h
	mov al, 0Ah
	int 29h
	ret
	
		
find_free_rsd_num: ;ch != 0 => NUM
	xor ax, ax
	xor cx, cx
	mov ch, MIN_NUM
	.loop:
		cmp ch, 0 ; overflow -> error
		je .ex_
		mov ah, ch
		mov al, RSD_NUM_STATUS
		push cx
		int MULTIPLEX
		pop cx
		cmp al, NUM_FREE
		je .ex_
		inc ch
		jmp .loop
	.ex_:
	ret
	
reg_to_str: ;->AX
    mov di, offset output
    mov cl, 4
rts1: rol ax, 4
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

    call_print output
    ret
