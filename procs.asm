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
