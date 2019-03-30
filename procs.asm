jmp main
str2dec_error db "Couldn't parse a number", "$"
mp_comb_error db "Combination of those mode and page number are illegal. Check help (/?)", "$"
mode_range_error  db "Ivalid mode number. Check help (/?)", "$"

SPACE = 20h

check_args_consistency proc
	cmp byte ptr mode_num, 1
	jbe zero_one_modes
	cmp byte ptr mode_num, 3
	jbe two_three_modes
	cmp byte ptr mode_num, 7
	je  seventh_mode
	jmp @@mode_error
	
zero_one_modes:
	cmp byte ptr page_num, 8
	jae @@error
	ret
	
two_three_modes:
	cmp byte ptr page_num, 4
	jae @@error
	ret
	
seventh_mode:
	cmp byte ptr page_num, 8
	jae @@error
	ret

@@error:
	call_print mp_comb_error
	jmp .ex_it
	
@@mode_error:
	call_print mode_range_error
	jmp .ex_it	
	
endp check_args_consistency

str2dec proc ;input: si
	push bx dx
    xor  ax, ax
	xor  dx, dx
	mov  dl, 10

.str2dec_loop:
	cmp cx, 0
	je  @@ret
    mov bl, [si*1]
	cmp bl, SPACE
	je 	@@ret
	cmp bl, '/'
	je 	@@ret
    sub bl, '0'
    cmp bl, 10
    jnb @@error

    mul dl
    add ax, bx
    call move_pointer
    jmp .str2dec_loop
	
@@error:
	call_print str2dec_error
	call_exit
 
@@ret:
    pop dx bx

	ret

endp str2dec	
	
move_pointer:
	inc si
	dec cx
	ret

skip_spaces:
	cmp cx, 0
	je .ex
	xor ah, ah
    mov al, [si*1]    ; letter
    mov bl, SPACE
    cmp bl, al
    je skip_char
	.ex:
    ret

    skip_char:
        call move_pointer
		cmp cx, 0
		je .ex
        jmp skip_spaces
