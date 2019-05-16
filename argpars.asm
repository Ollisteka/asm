	mov si, 81h
	xor cx, cx
	mov cl, ds:[0080h*1]

	cmp cl, 0
	jne @@parse_loop
	jmp @@prog

@@parse_loop:
	call skip_spaces
	
	cmp cx, 2
	jae @@2

	jmp @@prog
	
@@2:
	mov bl, '/'
	cmp [si*1], bl
	je @@3
	jmp @@args_error
@@3:
	call move_pointer
	mov bl, '?'
	cmp bl, [si*1]
	je @@args_help
	
@@try_length_parse:
	mov bl, 'l'
	cmp bl, [si*1]
	je @@length_parse
	mov bl, 'L'
	cmp bl, [si*1]
	jne @@try_blink_parse
	@@length_parse:
		push offset snake_init_length
		push offset @@double_arg_error
		push LENGTH_MASK
		call arg_parse; PAGE_MASK, error, page_num
		cmp [snake_init_length], 25
		ja @@big_snake_error
		cmp [snake_init_length], 0
		je @@small_snake_error
		jmp @@parse_loop

@@try_blink_parse:
	jmp @@args_error
	
	@@args_help:
	call_print help_args_msg
	jmp @@just_exit
	
	@@args_error:
	call_print error_msg
	jmp @@just_exit
	
	@@double_arg_error:
	call_print double_arg_err_msg
	jmp @@just_exit
	
	@@big_snake_error:
	call_print big_snake_err_msg
	jmp @@just_exit
	
	@@small_snake_error:
	call_print small_snake_err_msg
	jmp @@just_exit
	


error_msg   	db "Some error with args. Check help (/?).", "$"
double_arg_err_msg  db "You can't use the same argument twice", "$"
big_snake_err_msg  db "Snake init length is too large. Max is 25", "$"
small_snake_err_msg  db "Snake init length must be at leat 1", "$"
help_args_msg db "Play snake and enjoy your life!",CR,LF,"/s - self-cross mode:",CR,LF,"    0 - allowed;",CR,LF,"    1 - will cut a tail;",CR,LF,"    2 - deadly;",CR,LF,"/u - upper wall type:",CR,LF,"    0 - death wall;",CR,LF,"    1 - swap wall;",CR,LF,"    2 - teleport wall;",CR,LF,"/l - snake init length (default is X, max is 25);",CR,LF,"/f - food init amount (default is 3);",CR,LF,"/? - this help", "$"
args_flags db 0 ;X|X|X|X|X|X|L|F
LENGTH_MASK = 2