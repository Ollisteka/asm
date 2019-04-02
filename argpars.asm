	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	jne .parse_lp
	jmp .help
.parse_lp:
	call skip_spaces
	
	cmp cx, 2
	jae @@2
	
	mov al, MODE_MASK
	or al, PAGE_MASK
	test byte ptr flags, al
	jnz @@jmp_to_prog
	jmp .error
@@jmp_to_prog:
	jmp prog
	
@@2:
	mov bl, '/'
	cmp [si*1], bl
	je @@3
	jmp .error
@@3:
	call move_pointer
	mov bl, '?'
	cmp bl, [si*1]
	je .help

try_mode_parse:
	mov bl, 'm'
	cmp bl, [si*1]
	je mode_parse
	mov bl, 'M'
	cmp bl, [si*1]
	jne try_page_parse
	mode_parse:
		push offset mode_num
		push offset .double_arg_error
		push MODE_MASK
		call arg_parse; MODE_MASK, error, mode_num
		jmp .parse_lp

try_page_parse:
	mov bl, 'p'
	cmp bl, [si*1]
	je page_parse
	mov bl, 'P'
	cmp bl, [si*1]
	jne try_blink_parse
	page_parse:
		push offset page_num
		push offset .double_arg_error
		push PAGE_MASK
		call arg_parse; PAGE_MASK, error, page_num
		jmp .parse_lp
	
try_blink_parse:
	mov bl, 'b'
	cmp bl, [si*1]
	je set_blink
	mov bl, 'B'
	cmp bl, [si*1]
	jne .error
	set_blink:
		jmp_if_bit_set BLINK_MASK, .double_arg_error
		or byte ptr flags, BLINK_MASK
		call move_pointer
		jmp .parse_lp
	
	.help:
	call_print help_msg
	call_print help_mode_msg1
	call_print help_mode_msg2
	call_print help_mode_msg3
	call_print help_mode_msg4
	call_print help_page_msg1
	call_print help_page_msg2
	call_print help_page_msg3
	call_print help_blink_msg
	call_print help_help_msg
	jmp .ex_it
	
	.error:
	call_print error_msg
	jmp .ex_it
	
	.double_arg_error:
	call_print double_arg_err_msg
	jmp .ex_it
